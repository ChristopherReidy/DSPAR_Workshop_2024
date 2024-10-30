%PixelScalerPAT.m

%Scales image to large size for convolution with pixel kernel
%PAT is 'Put it All Together' solution

function [ImageOut] = PixelScalerPAT(ImageIn, scale, shape) 

% clc 
% clearvars
% close all

% ImageIn = ones(100,100,3);
% scale = 14;
% shape = 'round';

if isequal(shape, 'round')
    Filt = load('NormPxKernel_Round.mat');
elseif isequal(shape, 'square')
    Filt = load('NormPxKernel_Square.mat');
end

Filt10 = Filt.Px10n;
Filt14 = Filt.Px14n;
Filt20 = Filt.Px20n;
Filt25 = Filt.Px25n;
Filt40 = Filt.Px40n;

if scale == 10 %This is a hacky way to deal with this...
    Filt = Filt10;
elseif scale == 14
    Filt = Filt14;
elseif scale == 20
    Filt = Filt20;
elseif scale == 25
    Filt = Filt25;
elseif scale == 40
    Filt = Filt40;
end


DataLarge = imresize(ImageIn,scale,'nearest');

ROut=zeros(size(DataLarge,1),size(DataLarge,2));
GOut=zeros(size(DataLarge,1),size(DataLarge,2));
BOut=zeros(size(DataLarge,1),size(DataLarge,2));
PanelOut=zeros(size(DataLarge,1),size(DataLarge,2),3); 

ROut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,2);
GOut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,2);
BOut(1:scale:end,1:scale:end)=DataLarge(1:scale:end,1:scale:end,3);

GridImage = ROut;
GridImage(:,:,2) = GOut;
GridImage(:,:,3) = BOut;


tic
ImageR = conv2(ROut,Filt);
% ImageR = ImageR.^0.5;
% ImageR = uint16(ImageR.*(2^16-1));
toc
ImageG = conv2(GOut,Filt);
% ImageG = ImageG.^0.5;
% ImageG = uint16(ImageG.*(2^16-1));

ImageB = conv2(BOut,Filt);
% ImageB = ImageB.^0.5;
% ImageB = uint16(ImageB.*(2^16-1));

ImageOut = ImageR;
ImageOut(:,:,2) = ImageG;
ImageOut(:,:,3) = ImageB;


% figure(1)
% imshow(ImageOut)