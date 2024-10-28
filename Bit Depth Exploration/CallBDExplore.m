% function CallBDExplore

clc
clearvars
close all

BDRef = 18;



for ii = 1:8
    BD = BDRef-ii;
    GammaData = (0:255)./255;
    LinearData = GammaData.^2.2;
    LinearDataQuant = uint32(LinearData.*(2.^32-1));
    TruncatedData(ii,:) = BitDepthExplore(LinearDataQuant, BD);
end

figure(1)
for ii = 1:8
hold on
plot(0:255, (LinearDataQuant-TruncatedData(ii,:))./LinearDataQuant, 'linewidth',2)
end
hold off

xlabel('Input Gray Level','fontsize',14)
xlim([0,255])
ylabel('Fractional Error','fontsize',14)
ylim([-1,1])