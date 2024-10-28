function Iout = apply_MTF_function_upsample(Iin, ppdImg, FigFlag)    
         
        global PSFKern
        PSFKern(isnan(PSFKern)) = 0;

        scale = 2;
        Iin = imresize(Iin,scale,'nearest');
        ppdImg = ppdImg.*scale;
        
        [FreqX,FreqY,mtf_2d] = convertMTF1Dto2D(PSFKern(:,1),PSFKern(:,2));
        mtf_2d = mtf_2d/max(mtf_2d(:));
         
        [xGridDeg,yGridDeg,psf] = OtfToPsf(FreqX,FreqY,abs(mtf_2d));
        InterpSize = 1; 
        %inImgi = imresize(Iin, InterpSize, 'nearest');
        inImgi = Iin;
 
        Iout = nan(size(inImgi));
        
        
         
 
        for ii = 1 : 3
             %% Test the ieApplyPSF function
            %% Load 1DOTF and convert
 
 
            %% Get an image
 
            inImg = inImgi(:,:,ii);
            ppdImg = ppdImg*InterpSize;
 
            % Calculate axes
            dppImg = 1/ppdImg; % degrees per pixel
            [n,m] = size(inImg);
            x = (1:n)*dppImg; x = x - mean(x(:));
            y = (1:m)*dppImg; y = y - mean(y(:));
            [xGridDegIm,yGridDegIm] = meshgrid(x,y); 
 
 
            % title(sprintf('fov = [%0.2f %0.2f]',min(xGridDeg(:)),max(xGridDeg(:))));
 
            %% Convert PSF to MTF
 
            %xGridMinutes = xGridDeg*60;
            %yGridMinutes = yGridDeg*60;
            %[freqX_cycPerDeg,freqY_cycPerDeg,otf] = PsfToOtf(xGridMinutes,yGridMinutes,psf);
 
            freqX_cycPerDeg   = FreqX;
            freqY_cycPerDeg   = FreqY;
            otf               = mtf_2d;
            mtf = abs(otf);
 
 
            %% Convolve
            Iout(:, :, ii)  = ieApplyMTF(inImg, ppdImg, mtf, freqX_cycPerDeg, freqY_cycPerDeg);          
        end
        
        Iout = imresize(Iout,(1/scale));
        
        
        %Iout = imresize(Iout, 1/InterpSize, 'nearest');
        %% Show both images
        if FigFlag
            figure();
 
            subplot(1,4,1);
            imshow(Iin);
 
 
            subplot(1,4,2);
            imagesc(xGridDeg(1,:),yGridDeg(:,1),psf); 
            axis image; colormap(gray);
            xlabel('deg'); 
            title('PSF')        
 
 
            subplot(1,4,3);
            imagesc(freqX_cycPerDeg(1,:),freqY_cycPerDeg(:,1),mtf); 
            axis image; colormap(gray);
            xlabel('cyc/deg');
            title('MTF')            
 
            subplot(1,4,4);
            imshow(Iout); 
        end
        %Iout = outImg;
end