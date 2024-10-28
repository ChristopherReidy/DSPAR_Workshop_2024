%PlotPipelineBDError.m

clc
clearvars
close all

Gamma = 2.0;
SourceBD = 12;
indir = strcat('Images/',num2str(SourceBD),'bit_Source/Gamma',num2str(Gamma),'/')

count = 1;
for PipeBD = 9:32
    data = imread(strcat(indir,'SrcBD',num2str(SourceBD),'_PipeBD',num2str(PipeBD),'.png'));
    DataLine(count,:) = data(1,:,1);
    count = count+1;
end

x = 0:length(DataLine)-1;
% hold on
% for dex0 = 1:size(DataLine,1);
%     figure(1)
%     plot(x, DataLine(dex0,:),'linewidth',2)
%     dex0
% end
% hold off

reference = imread(strcat('Images/',num2str(SourceBD),'bit_Source/GrayRamp',num2str(SourceBD) ,'bit.png'));
referenceLine = repmat(reference(1,:,1),[size(DataLine,1),1]);
referenceLine = double(referenceLine);
referenceLine = (2^16-1).*referenceLine./max(referenceLine,[],'all');
DataLine = double(DataLine);

Error = (DataLine-referenceLine)./referenceLine;

PipeRange = 10:floor(Gamma.*SourceBD)+1
for Pipedex = PipeRange(1):PipeRange(end)
    figure(2)
    hold on
    plot(x(2:end), Error(Pipedex-PipeRange(1)+1, 2:end),'linewidth',2)
end

for Pipedex = PipeRange(1):PipeRange(end) %Create Legend Entries
    LegendArray(Pipedex-PipeRange(1)+1) = {strcat(num2str(Pipedex),'-bit Pipe')}; 
end
legend(LegendArray,'Location','southeast','FontSize',14)
title(strcat('Gray Error With',32,num2str(SourceBD),'-bit Source'),'FontSize',18)
subtitle(strcat('Gamma =',32,num2str(Gamma)),'FontSize',14)
xlabel(strcat('Gray Level -',32,num2str(SourceBD),'-Bit (Max =',32,num2str(2^SourceBD-1),')'),'FontSize',14)
ylabel('Fractional Error','FontSize',14)
xlim([1, floor(max(x).*0.25)])
hold off





