PSFKern = xlsread('system MTF estimation.xlsx');
PSFKern(isnan(PSFKern)) = 0;
 
[FreqX,FreqY]=freqspace((length(PSFKern(:,1))-1)*2+1,'meshgrid'); 
% Use the resolution 
FreqX=FreqX*(max(PSFKern(:,1))); 
FreqY=FreqY*(max(PSFKern(:,1)));  
 
% Distance map (frequency domain)
f=sqrt(FreqX.^2+FreqY.^2); 
f=(f>0).*f+0.0001*(f==0);   % To avoid singularity at zero frequency    
 
MTF1= [flipud(PSFKern(2:end,2)); PSFKern(:,2)];
fx  = [-flipud(PSFKern(2:end,1)); PSFKern(:,1)];
%1D MTF
% Calculating PSF (1D)
PSF1=abs(fftshift(ifft(fftshift(MTF1))));
% Conversion from 1D to circularly symmetric 2D
PSF1_R = interp1(fx,PSF1,f,'cubic'); % For each value of r in the matrix, find the corresponding PSF1-value.
PSF1_R = PSF1_R./nansum(PSF1_R(:)); % Normalise. NaNs are present (and ignored) because r is larger than X in the corners of the image.