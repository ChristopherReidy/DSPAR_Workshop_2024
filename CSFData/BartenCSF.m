function [CSF] = BartenCSF(DispLum, BackLum)
%BartenContrastSensitivity
%From Barten 1999
%CReidy, 2021

L = DispLum + BackLum;
L = DispLum + 0;
FieldSize = 60*40; %field size/area in deg^2

%Define Constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
k = 3; %SNR
sigma0 = 0.5; %arcmin, SD of line spread small pupil
sigma0 = sigma0./60;
Cab = 0.08; %arcmin/mm, correction to line spread, large pupil
Cab = Cab/60;
T = 0.1; %s, eye integration time.  Assumes display on constanly, modify for short persistance
Xmax = 12; %deg
Nmax = 15; %cycles
eta = 0.03; %Eye QE
phi = 3*10^-8; %sec/deg^2 Neural noise spectral density
u0 = 7; %cyc/deg Max freq of lateral inhibition
p = 1.221*10^6; %photons/sec/deg^2/Td - for white phosphor light, should define for our three uLEDs
u = 0:1e-4:60;  %Spatial Frequency in cyc/deg

X = sqrt(FieldSize); %Use this to change object size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% % %Barten Pupil Size Model (Modified Le Grand)
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% d2 = 5-3*tanh(0.4*log(L*FieldSize./(40*40))); %Pupil dia vs feature size %Ed's Calc
d = 5-3*tanh(0.4*log10(L*X.^2./(FieldSize))); %Pupil dia vs feature size, Chris' Calc
r = d./2;
area = pi.*r.^2; %pupil area
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %Watson Pupil Size Model (2012)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mono = 1; %0.1 for monocular, 1 for binocular
% age = 25;
% 
% SD_Param = (FieldSize*L*mono/846)^0.41;
% Dsd = 7.75-5.75.*SD_Param/(2+SD_Param); %Stanley Davies Pupil Size Model
% 
% S = 0.021323-0.0095623*Dsd; %Age Slope
% y0 = 28.58;
% AgeEffect = (age-y0)*S;
% d = AgeEffect+Dsd;
% r = d./2;
% area = pi.*r.^2; %pupil area
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Define other components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
E = L.*area.*(1-(d./9.7).^2+(d./12.4).^4); %Retinal Illuminance

sigma = sqrt(sigma0^2+(Cab.*d).^2);

MTF = exp(-pi^2*sigma^2.*u.^2);
MTFr = MTF./k;

alpha = 2/T;
beta = (1/X^2)+(1/Xmax^2)+(u.^2./Nmax^2);
gamma = ((1./(eta*p*E))+(phi./(1-exp(-(u./u0).^2))));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CSF(:,1) = u;
CSF(:,2) = MTFr./((alpha.*beta.*gamma).^(1/2));
end

