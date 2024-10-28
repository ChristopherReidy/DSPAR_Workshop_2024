function outImg  = ieApplyMTF(inImgi, ppdImg, mtf, freqX_cycPerDeg, freqY_cycPerDeg)
%ieApplyPSF Use ISET functions to convolve PSF data with an image.
%   The benefit of using ISET functions instead of convolving "by hand," is
%   that ISET can keep track of image and PSF scales for us and pad
%   correctly. A lot of this is taken from "s_opticsSIExamples.m" in
%   ISETCam.
%
% Required Inputs:
%       inImg              - the input image. Should be monochrome.
%       ppdImg             - the spatial sampling of the image in pixels
%                            per degree.
%       freqX_cycPerDeg    - frequency support in the x-direction (2D
%                            matrix, often an output from meshgrid). Should
%                            be in cyc/deg
%       freqY_cycPerDeg    - frequency support in the y-direction (2D
%                            matrix, often an output from meshgrid). Should
%                            be in cyc/deg.
%
% Outputs:
%       outImg   - the output image, given as an RGB image
%
% TL 6/19
 
%% Padding
% Pad the optical image to allow for light spread.  Also, make sure the row
% and col values are even.
imSize   = size(inImgi);
[~, IndimSize] = max(imSize);
imSizeDiff = (max(imSize) - min(imSize))/2;
%padSize  = round(imSize/8);
N = 2;
padSizei = N*floor((imSize/2)/N);
 
% Make it square
if IndimSize == 1
    padSize(2) = padSizei(1)+imSizeDiff;
    padSize(1) = padSizei(2)+imSizeDiff; 
else
    padSize(1) = padSizei(2)+imSizeDiff;
    padSize(2)  = padSizei(1)+imSizeDiff;
end
     
padSize(3) = 0;
padval = 0;
inImg = padarray(inImgi,padSize,padval,'both');
 
%% Calculate horizontal FOV and distance given the pixels per degree
hfov = size(inImg,2)*1/ppdImg;
wfov = size(inImg,1)*1/ppdImg;
 
%% Convolution
[nRows, nCols] = size(inImg);
maxFrequencyCPD = [(nCols/2)/wfov, (nRows/2)/hfov];
 
% DC = 1.  The first coefficient, K, past the Nyquist is (K-1) > N/2,
% K > (N/2 + 1).  This is managed in the unitFrequencyList routine.
fx1D = unitFrequencyList(nCols)*maxFrequencyCPD(1);
fy1D = unitFrequencyList(nRows)*maxFrequencyCPD(2);
[fx, fy] = meshgrid(fx1D,fy1D);
 
mtf = interp2(freqX_cycPerDeg, freqY_cycPerDeg, mtf, fx, fy, '*linear',0);
mtf = fftshift(mtf);
 
% Put the image center in (1,1) and take the transform.
imgFFT = fft2(fftshift(inImg));
 
% Multiply the transformed otf and the image.
% Then invert and put the image center in  the center of the matrix
outImg = abs(ifftshift(ifft2(mtf .* imgFFT)));
 
%% Remove the padding
%padSize = N*floor((imSize/2)/N);
outImg = imcrop(outImg,...
    [padSize(2)+1 padSize(1)+1 imSize(2)-1 imSize(1)-1]);
 
end