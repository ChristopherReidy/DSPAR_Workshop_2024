%PutItAllTogether.m

clc
clearvars
close all

%Simulation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PipeBD = 14; %Pipeline bit depth
DisplayPPD = 120; %Simulated display resolution in pixels per degree
global PSFKern
PSFKern = readmatrix('SimpleSineMTF.csv'); %You can put any MTF here

scale = 10; %Pixel Scale, accepts 10,14,20,25,40 by default
shape = 'square'; %Px kernel shape, accepts round or square by default


%Contrast Assembly Parameters.  Struct makes it easy to pass all into other functions
params.CalibratedOutput = 1000; %Images to be shown on display of this brightness.  This is your monitor's brightness in nits

params.ContrastMethod = 0; %0 uses global contrast, %any other value uses local contrast.  Make a version that uses both
params.CR = 50; %Contrast Ratio XX:1
params.ContrastModel = 'ContrastKernelExample.mat'; %Contrast Kernel spans -+ 2 deg @ 30 PPD.  Resize and renormalize for your system!
params.ContrastScale = 50./params.CR; %Scaler used to hit correct contrast ratio

params.foreground_luminance = 750; %May need to modify behavior 
params.background_luminance = 250; %For calibrated output, foreground_luminance+background_luminance*stack_transmission should be < CalibratedOutput
params.optical_transmission = 0.96; %Transmission of normal 1.5 index glass with no coatings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Load Image
Image = imread('Peacock.png');
BackgroundImage = imread('McGill.png'); %This will be handled inside ImageAssemblyContrast.m.  It could be brought outside too


%for faster compute and less mem consumption, reduce size of image
Image = imresize(Image, 0.125, 'bilinear');

%Linearize
Image = uint16(Image); %Cast to 16 uint16
Image = Image.^2; %Linearize, assuming gamma =2.  we can use uint32 for gamma = 2.2+


%Truncate to n bits
Image = bitshift(Image,-(16-PipeBD)); %Truncate
Image = bitshift(Image,(16-PipeBD));  %Expand to fill uintXX
Image = double(Image)./(2^16-1); %Recast as double scaled 0:1 for down stream ops

%Large Scale Px Sim
% % % % % PixelScaler.m %Make this a function, with image and px kernel size as inputs...
[ImageOutPx] = PixelScalerPAT(Image, scale, shape) ;


ImageOutMTF = apply_MTF_function_upsample(ImageOutPx, DisplayPPD.*scale, 0); % Remember to scale PPD here by the same factor as your px kernel!
GammaEncImage = ImageAssemblyContrast(ImageOutMTF, BackgroundImage, params);


figure(1)
imshow(ImageOutPx.^(1/2.2))

figure(2)
imshow(ImageOutMTF.^(1/2.2))

figure(3)
imshow(GammaEncImage)




%%%%%%%%%               %Since input is already linearized, we can by pass that step inside 
%%%%%%%%%               %Define output ImageOut




% The last 4 steps are basically in ImageAssemblyContrast.m
% You can load the background image in this wwapper instead of that
% function
%The output, GammaEncImage is what we want to see!