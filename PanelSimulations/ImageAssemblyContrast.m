% ImageAssembly.m
% function [GammaEncImage] = ImageAssemblyLargeLCoSContrast(Image, BackgroundImage, ContrastImage,ImageIndex,M_display_to_P3, M_sRGB_to_P3, vertical_resolution, horizontal_resolution)
%Take FG/BG images, assemble for output, convert double to uint16

        CalibratedOutput = 900; %Images to be shown on display of this brightness

        ContrastMethod = 0;
        CR = 50; %Contrast Ratio XX:1
        ContrastModel = 'ContrastKernelExample.mat';
        ContrastScale = 15./CR; %Scaler used to hit correct contrast ratio

        foreground_luminance = 500;
        background_luminance = 500; %For calibrated output, foreground_luminance+background_luminance*stack_transmission shoudl be < CalibratedOutput
        optical_transmission = 0.96; %Transmission of normal 1.5 index glass with no coatings

        if ~isempty(BackgroundImage)
            BackgroundImage = (double(BackgroundImageImage)./255).^(2.2);
            BackgroundImage = imresize(BackgroundImage, [vertical_resolution, horizontal_resolution], 'bilinear');
            Background_P3 = reshape(reshape(BackgroundImage,[],3) * M_sRGB_to_P3.',vertical_resolution,horizontal_resolution,3);
            
        else
            BackgroundImage_P3 = zeros(vertical_resolution, horizontal_resolution, 3);
            background_luminance = 0;
        end 
    
        if ContrastMethod == 0
            Ldispmin = foreground_luminance/CR; % minimum display luminance without ambient light
            if CalibratedOutput ~= 0
                combined_image =((foreground_luminance-Ldispmin).*Image/255 + Ldispmin + cfg.stack_transmission(BGIndex).*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                    ./ (CalibratedOutput);
            else
                combined_image =((cfg.foreground_luminance-Ldispmin).*Image/255 + Ldispmin + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                        ./ (optical_transmission.*background_luminance + cfg.foreground_luminance);
            end
        else
            load(ContrastModel)
            ContrastComponent = zeros(size(Image,1)+size(ContrastKernel,1)-1,size(Image,2)+size(ContrastKernel,1)-1,3);

            for cc = 1:3
                ContrastComponent(:,:,cc) = conv2((Image(:,:,cc)),ContrastKernel.*ContrastScale);
            end
            ContrastComponent = Depad(ContrastComponent, 60);
            Image = Image+ContrastComponent;

            if CalibratedOutput ~= 0
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                            ./ (CalibratedOutput);
            else
                combined_image =((foreground_luminance).*Image + optical_transmission.*((background_luminance-BGDisplayMin).*Background_P3/255)+BGDisplayMin) ...
                            ./ (optical_transmission.*background_luminance + cfg.foreground_luminance);
            end
        end

        %Gamma encode double image, convert to uint16
        GammaEncImage = (clip(combined_image,0,1)).^(1/2.2); %TODO: make sure of image class for frame > 1
        GammaEncImage = uint16(GammaEncImage.*(2^16-1));
