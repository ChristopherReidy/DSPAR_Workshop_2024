%PutItAllTogether.m

clc
clearvars
close all

%Simulation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PipeBD = 14; %Pipeline bit depth
DisplayPPD = 60; %Simulated display resolution in pixels per degree
global PSFKern
PSFKern = readmatrix('SimpleSineMTF.csv'); %You can put any MTF here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Load Image
image = imread('Peacock.png');


%Linearize
image = uint16(image); %Cast to 16 uint16
image = image.^2; %Linearize, assuming gamma =2.  we can use uint32 for gamma = 2.2+


%Truncate to n bits
image = bitshift(image,-(16-PipeBD)); %Truncate
image = bitshift(image,(16-PipeBD));  %Expand to fill uintXX
image = double(image)./(2^16-1); %Recast as double scaled 0:1 for down stream ops

%Large Scale Px Sim
% % % % % PixelScaler.m %Make this a function, with image and px kernel size as inputs...

%Apply MTF
% call apply_MTF_function_upsample.m 
% MTFImageOut = apply_MTF_function_upsample(image, PPD, 0) 
% Remember to scale PPD here by the same factor as your px kernel!



ImageAssemblyContrast(Image, BackgroundImage, M_sRGB_to_P3, vertical_resolution, horizontal_resolution)
%%%%%%%%%               %Since input is already linearized, we can by pass that step inside 
%%%%%%%%%               %Define output ImageOut




% The last 4 steps are basically in ImageAssemblyContrast.m
% You can load the background image in this wwapper instead of that
% function
%The output, GammaEncImage is what we want to see!