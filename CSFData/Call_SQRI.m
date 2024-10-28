%Call_SQRI

clc
clearvars
close all

 MTF = readmatrix('SimpleSineMTF.csv');

 DispLum = 1000; %Display Luminance in Nits %Made up number C.Reidy 
 BackLum = 0./pi(); %Background illuminance converting lux to nits, assuming lambertian surface
 DispCR = 50; %Display contrast ratio 50:1 %Made up number C.Reidy
 StackTrans = 0.0; %Transmission of optical stack 
 
 [MTF_Out] = LumWeightMTF(MTF);
 
for DispLum = 200:200:1000 
    [SQRI, CSF] = SqriLum(MTF_Out, DispLum, BackLum, DispCR, StackTrans);
   
    figure(1)
    hold on
    plot((CSF(:,1)),(CSF(:,2)),'LineWidth',2)
end

hold off

xlabel('Spatial Frequency (lp/deg)','FOntSize',14)
ylabel('Contrast Sensitivity','FontSize',14)
title('Barten CSF vs Luminance','FontSize',18)
legend('200 nits','400 nits','600 nits','800 nits','1000 nits')



    