function CallBDExploreImage

clc
clearvars
close all

BD = 10; %Used for truncation in linear domain

Image = imread('8_bit_Grays_Cine4k.png');
ImageRef = Image;

if isequal(class(Image),'uint8')
    Image = double(Image)./255;
    Image = Image.^2.2; %Linearize gamma encoded data
elseif isequal(class(Image),'uint16')
    Image = double(Image)./(2^16-1);
    Image = Image.^2.2; %Linearize gamma encoded data
end

TruncatedImage = BitDepthExplore(Image, BD);

GammaTruncImage = TruncatedImage.^(1/2.2);

figure(1)
imshow(ImageRef)

figure(2)
imshow(GammaTruncImage )

