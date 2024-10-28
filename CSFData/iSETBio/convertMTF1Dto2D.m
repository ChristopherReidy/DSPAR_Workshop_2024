function [FreqX,FreqY,mtf_2d] = convertMTF1Dto2D(fsupport_1d,mtf_1d)
 
 
% N_1d = length(mtf_1d);
N = (length(mtf_1d)*2)-1;
 
%{
ni = 0:N; % Get back negative frequencies
[X,Y] = meshgrid(ni,ni);
X = X-N_1d; Y = Y-N_1d;
 
dist_px = sqrt(X.^2+Y.^2);
dist_px_v = dist_px(:);
%}
 
%%
[FreqX,FreqY]=freqspace([N N],'meshgrid');
FreqX=FreqX*max(fsupport_1d);
FreqY=FreqY*max(fsupport_1d);
 
% Distance map (frequency domain)
f=sqrt(FreqX.^2+FreqY.^2);
f=(f>0).*f+0.0001*(f==0);   % To avoid singularity at zero frequency
 
%%
 
values = interp1(fsupport_1d,mtf_1d,f(:),'linear',0);
if(sum(isnan(values)) ~= 0)
    warning('Had to convert some NaN values to zeroes when convert from 1D MTF to 2D MTF.')
    values(isnan(values)) = 0;
end
mtf_2d = reshape(values,[N N]);
 
end