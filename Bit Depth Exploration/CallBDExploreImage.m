function CallBDExploreImage

clc
clearvars
close all

BD = 10; %Used for truncation in linear domain

Image = imread('8bitGrayRamp.png');
ImageRef = Image;

Image = double(Image)./255;
Image = Image.^2.2; %Linearize gamma encoded data

TruncatedImage = BitDepthExplore(Image, BD);

GammaTruncImage = TruncatedImage.^(1/2.2);

figure(1)
imshow(ImageRef)

figure(2)
imshow(GammaTruncImage )

