function [MTF_Out] = LumWeightMTF(MTF)

% Define Parameters and Optical MTF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MTF = readmatrix('ExampleRGB_MTF.csv'); %Use for testing
data = MTF;
subpxres = 4;  %Gives fine structure to MTF simulation
LumFactors = [0.2126, 0.7152, 0.0722]; %Luminance Weighting Factors, sRGB here.  Modify for other spaces
image = zeros(500,500,3);
image(:,248:251,:) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Apply Optical MTFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PSFKern;
PSFKern = data(:,[1,2])
MTF_AppliedR = clip(apply_MTF_function_upsample(repmat(image(:,:,1), [1,1,3]), 30*subpxres, 0),0,255); %Clip is because apply_MTF_function_upsample sometimes returns values >1
MTF_Applied(:,:,1) = MTF_AppliedR(:,:,1);
redMTF = PSFKern;
clear PSFKern MTF_AppliedR

global PSFKern;
PSFKern = data(:,[1,3])
MTF_AppliedG = clip(apply_MTF_function_upsample(repmat(image(:,:,2), [1,1,3]), 30*subpxres, 0),0,255); 
MTF_Applied(:,:,2) = MTF_AppliedG(:,:,2);
greenMTF = PSFKern;
clear PSFKern MTF_AppliedG

global PSFKern;
PSFKern = data(:,[1,4])
MTF_AppliedB = clip(apply_MTF_function_upsample(repmat(image(:,:,3), [1,1,3]), 30*subpxres, 0),0,255); 
MTF_Applied(:,:,3) = MTF_AppliedB(:,:,3);
blueMTF = PSFKern;
clear PSFKern MTF_AppliedB

MTF_Applied = MTF_Applied./max(max(max(MTF_Applied)));
MTFAppliedLum = LumFactors(1).*MTF_Applied(:,:,1)+LumFactors(2).*MTF_Applied(:,:,2)+LumFactors(3).*MTF_Applied(:,:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Calulate Lum Weighted MTF via DFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = (subpxres*30);   % Sampling frequency                    
T = 1/Fs;             % Sampling period

Source_LSFLum = sum(MTFAppliedLum,1); %create single LSF from integration of data
Source_LSFLum = Source_LSFLum./max(Source_LSFLum); %Normalize
DC_Offset_SrcLum = min(Source_LSFLum); %Used to subtract DC term from LSF

L_SrcLum = length(Source_LSFLum);             % Length of signal
t_SrcLum = (0:L_SrcLum-1)*T;                   
f_SrcLum=Fs*(0:(L_SrcLum/2))/L_SrcLum;         
MTF_SrcLum = ifftshift(abs((fftshift(fft(Source_LSFLum-DC_Offset_SrcLum)))));
MTF_Src_OutLum = MTF_SrcLum./max(MTF_SrcLum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Interpolate to match CSF Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MTF_Out(:,1) = 0:0.1:60;
MTF_Out(:,2) = interp1(f_SrcLum, MTF_Src_OutLum(1:length(f_SrcLum)), MTF_Out(:,1)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end