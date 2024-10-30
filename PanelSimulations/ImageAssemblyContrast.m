% ImageAssembly.m
function [GammaEncImage] = ImageAssemblyContrast(Image, BackgroundImage, params)
%Take FG/BG images, assemble for output, convert double to uint16

% Assumptions
% Image (your foreground image) is linear
% BackgroundImage is gamma encoded and sRGB primaries



%Set Parameters.  Now defined outside this function in var params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CalibratedOutput = params.CalibratedOutput; %Images to be shown on display of this brightness.  This is your monitor's brightness in nits

ContrastMethod = params.ContrastMethod; %0 uses global contrast, %any other value uses local contrast.  Make a version that uses both
CR = params.CR; %Contrast Ratio XX:1
ContrastModel = params.ContrastModel; %Contrast Kernel spans -+ 2 deg @ 30 PPD.  Resize and renormalize for your system!
ContrastScale = params.ContrastScale; %Scaler used to hit correct contrast ratio

foreground_luminance = params.foreground_luminance; %May need to modify behavior 
background_luminance = params.background_luminance; %For calibrated output, foreground_luminance+background_luminance*stack_transmission should be < CalibratedOutput
optical_transmission = params.optical_transmission; %Transmission of normal 1.5 index glass with no coatings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Background Image Handling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vertical_resolution = size(Image,1);
horizontal_resolution = size(Image,2);

    if ~isempty(BackgroundImage)
        BackgroundImage = (double(BackgroundImage)./255).^(2.2);
        BackgroundImage = imresize(BackgroundImage, [vertical_resolution, horizontal_resolution], 'bilinear'); % Control for BG aspect ratio here
        Background_P3 = BackgroundImage;%The McGill BG image is already P3
    else
        Background_P3 = zeros(vertical_resolution, horizontal_resolution, 3);
        background_luminance = 0;
    end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Generate contrast, add to foreground image, assemble into single composite image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ContrastMethod == 0
            %Global Contrast
            Ldispmin = foreground_luminance/CR; % minimum display luminance without ambient light
            
            if CalibratedOutput ~= 0 %May need to modify behavior for FG+BG > monitor brightness
                combined_image =((foreground_luminance-Ldispmin).*Image + Ldispmin + optical_transmission.*((background_luminance-Ldispmin).*Background_P3)+Ldispmin) ...
                    ./ (CalibratedOutput);
            else
                combined_image =((foreground_luminance-Ldispmin).*Image + Ldispmin + optical_transmission.*((background_luminance-Ldispmin).*Background_P3)+Ldispmin) ...
                        ./ (optical_transmission.*background_luminance + foreground_luminance);
            end
        
        else
            Ldispmin = 0;

            %Local Contrast
            load(ContrastModel)
            ContrastComponent = zeros(size(Image,1)+size(ContrastKernel,1)-1,size(Image,2)+size(ContrastKernel,1)-1,3);

            for cc = 1:3
                ContrastComponent(:,:,cc) = conv2((Image(:,:,cc)),ContrastKernel.*ContrastScale);
            end
            ContrastComponent = Depad(ContrastComponent, 60);
            Image = Image+ContrastComponent;

            if CalibratedOutput ~= 0 %May need to modify behavior for FG+BG > monitor brightness
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-Ldispmin).*Background_P3)+Ldispmin) ...
                            ./ (CalibratedOutput);
            else
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-Ldispmin).*Background_P3)+Ldispmin) ...
                            ./ (optical_transmission.*background_luminance + foreground_luminance);
            end
        
            %Add a condition which can use both cntrast models

        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Gamma encode double image, convert to uint16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        GammaEncImage = (clip(combined_image,0,1)).^(1/2.2); 
        GammaEncImage = uint16(GammaEncImage.*(2^16-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%