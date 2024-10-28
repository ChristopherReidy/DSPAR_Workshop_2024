%PanelScaler.m

%Scales image to large size for convolution with pixel kernel

clc 
clearvars
close all

imscale = 14;
scale = 14;

load('PxKernel_Round.mat');
load('NormPxKernel_Round.mat');

input = imread(strcat('Images/8bit_Source/8_bit_Grays_Cine4k.png'));

if isa(input,'uint16')
    data = double(input);
    data = data./(2^16-1);
    data = data.^2.2;
elseif isa(input,'uint8')
    data = double(input);
    data = data./(2^8-1);
    data = data.^2.2;
end

DataLarge = imresize(data,imscale,'nearest');

ROut=zeros(size(DataLarge,1),size(DataLarge,2));
GOut=zeros(size(DataLarge,1),size(DataLarge,2));
BOut=zeros(size(DataLarge,1),size(DataLarge,2));
PanelOut=zeros(size(DataLarge,1),size(DataLarge,2),3); 

ROut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,2);
GOut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,2);
BOut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,3);

Filt = Px10n;
tic
ImageR = conv2(ROut,Filt);
ImageR = ImageR.^0.5;
ImageR = uint16(ImageR.*(2^16-1));
toc
ImageG = conv2(GOut,Filt);
ImageG = ImageG.^0.5;
ImageG = uint16(ImageG.*(2^16-1));

ImageB = conv2(BOut,Filt);
ImageB = ImageB.^0.5;
ImageB = uint16(ImageB.*(2^16-1));

ImageOut = ImageR;
ImageOut(:,:,2) = ImageG;
ImageOut(:,:,3) = ImageB;

