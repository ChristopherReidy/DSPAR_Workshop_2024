% ImageAssembly.m
function [GammaEncImage] = ImageAssemblyContrast(Image, BackgroundImage, M_sRGB_to_P3, vertical_resolution, horizontal_resolution)
%Take FG/BG images, assemble for output, convert double to uint16

% Assumptions
% Image (your foreground image) is linear
% BackgroundImage is gamma encoded and sRGB primaries



%Set Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CalibratedOutput = 1000; %Images to be shown on display of this brightness.  This is your monitor's brightness in nits

        ContrastMethod = 0; %0 uses global contrast, %any other value uses local contrast.  Make a version that uses both
        CR = 50; %Contrast Ratio XX:1
        ContrastModel = 'ContrastKernelExample.mat'; %Contrast Kernel spans -+ 2 deg @ 30 PPD.  Resize and renormalize for your system!
        ContrastScale = 50./CR; %Scaler used to hit correct contrast ratio

        foreground_luminance = 500; %May need to modify behavior 
        background_luminance = 500; %For calibrated output, foreground_luminance+background_luminance*stack_transmission should be < CalibratedOutput
        optical_transmission = 0.96; %Transmission of normal 1.5 index glass with no coatings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Background Image Handling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(BackgroundImage)
            BackgroundImage = (double(BackgroundImageImage)./255).^(2.2);
            BackgroundImage = imresize(BackgroundImage, [vertical_resolution, horizontal_resolution], 'bilinear'); % Control for BG aspect ratio here
            Background_P3 = reshape(reshape(BackgroundImage,[],3) * M_sRGB_to_P3.',vertical_resolution,horizontal_resolution,3);
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
                combined_image =((foreground_luminance-Ldispmin).*Image/255 + Ldispmin + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                    ./ (CalibratedOutput);
            else
                combined_image =((cfg.foreground_luminance-Ldispmin).*Image/255 + Ldispmin + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                        ./ (optical_transmission.*background_luminance + cfg.foreground_luminance);
            end
        
        else
            %Local Contrast
            load(ContrastModel)
            ContrastComponent = zeros(size(Image,1)+size(ContrastKernel,1)-1,size(Image,2)+size(ContrastKernel,1)-1,3);

            for cc = 1:3
                ContrastComponent(:,:,cc) = conv2((Image(:,:,cc)),ContrastKernel.*ContrastScale);
            end
            ContrastComponent = Depad(ContrastComponent, 60);
            Image = Image+ContrastComponent;

            if CalibratedOutput ~= 0 %May need to modify behavior for FG+BG > monitor brightness
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                            ./ (CalibratedOutput);
            else
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                            ./ (optical_transmission.*background_luminance + cfg.foreground_luminance);
            end
        
            %Add a condition which can use both cntrast models

        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Gamma encode double image, convert to uint16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        GammaEncImage = (clip(combined_image,0,1)).^(1/2.2); 
        GammaEncImage = uint16(GammaEncImage.*(2^16-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%