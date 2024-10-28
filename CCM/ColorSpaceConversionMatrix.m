%ColorSpaceConversionMatrix.m

%Generates RGB Native <--> RGB Content Matrices from a given set of color primaries and
%white points

%RGB Primaries and WP data from industry standards
%C. Reidy 2023

clc
clearvars
close all

%Define Display Gamut (Here using sRGB, change to measured chromaticity
%coordinates from tristiumus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xrm = 0.64; yrm = 0.33;
xgm = 0.30; ygm = 0.60;
xbm = 0.15; ybm = 0.06;
xwpm = 0.3127; ywpm = 0.3290;

displayGamut = [xrm, yrm; xgm, ygm; xbm, ybm];
displayWP = [xwpm, ywpm];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Define Content Gamut (make sure native gamut > content gamut)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imageChromaticities = 'sRGB';

if isequal(imageChromaticities,'P3')
    xr = 0.680; yr = 0.320;
    xg = 0.265; yg = 0.690;
    xb = 0.150; yb = 0.060;
    xw = 0.3127; yw = 0.3290; 
elseif isequal(imageChromaticities,'sRGB')
    xr = 0.64; yr = 0.33;
    xg = 0.30; yg = 0.60;
    xb = 0.15; yb = 0.06;
    xw = 0.3127; yw = 0.3290; 
end

contentGamut = [xr, yr; xg, yg; xb, yb];
contentWP = [xw, yw];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculate transfer matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M_inv_display, M_display] = RGB_XYZ_Matrices(displayGamut, displayWP);
[M_inv_content, M_content] = RGB_XYZ_Matrices(contentGamut, contentWP);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculate RGB->R'G'B' matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_Conversion = M_inv_display*M_content; %M_content*[R;G;B]=[X;Y;Z].  M_inv_display*[X;Y;Z]=[R';G';B']
M_Conversion(abs(M_Conversion)<1e-5) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Apply to example image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load image and linearize
TestImage = imread('TestImage.png'); %This is uint8 bit
LinearTestImage = (double(TestImage)./255).^(2.2);

%Vectorize image data
Resolution = [size(LinearTestImage,1),size(LinearTestImage,2)];
LinearTestImage_Line = reshape(LinearTestImage,[],3);

%Apply CCM Matrix
ColorMappedOutput_Line = M_Conversion*LinearTestImage_Line'; %Apply the matrix (note transpose operation on the line image data)

Output(:,:,1)= reshape(ColorMappedOutput_Line(1,:),Resolution);
Output(:,:,2)= reshape(ColorMappedOutput_Line(2,:),Resolution);
Output(:,:,3)= reshape(ColorMappedOutput_Line(3,:),Resolution); %This output is still linearized

%Gamma encode, because we want to show on gamma encoded display
GammaOutput = Output.^(1/2.2);
GammaOutput16bit = uint16((2^16-1).*Output); %Scale normalized data from 0-1 to 0-2^16-1
GammaOutput8bit  = uint8(bitshift(GammaOutput16bit,-8)); %Truncate to 8-bits

figure(1)
imshow(TestImage)

figure(2)
imshow(GammaOutput8bit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

