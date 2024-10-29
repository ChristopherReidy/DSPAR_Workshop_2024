% MTF_Example.m
clc
clearvars
close all

%Define Parameters
global PSFKern
PSFKern = readmatrix('SimpleSineMTF.csv'); %You can put any MTF here. The default is pretty good :-)
PPD = 60; %angular resolution of image in Px per degree


%Load image and linearize
image = imread("Peacock.png");
image = double(image)./255;
image = image.^(2.2);

Iout = apply_MTF_function_upsample(image, PPD, 0); %apply MTF
Iout = Iout.^(1/2.2); %Gamma Encode


figure(2)
imshow(Iout)




