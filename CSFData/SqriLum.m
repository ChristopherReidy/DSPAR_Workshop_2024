function [SQRI_out, CSF_out] = SqriLum(MTF, DispLum, BackLum, DispCR, StackTrans) 

% Calulate CSF from Barten
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSF = BartenCSF(DispLum, BackLum);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Interpolate MTF to match CSF Spatial Frequency Spacing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MTFInterp(:,1) = CSF(:,1);
MTFInterp(MTFInterp > max(MTF(:,1)))=[];
MTFInterp(:,2) = interp1(MTF(:,1), MTF(:,2), MTFInterp(:,1));
CSF(CSF(:,1) > max(MTF(:,1)),:) = [];

CSF(1,1) = 1e-10; %Prevents divide by zero at 0 lp/deg
MTFInterp(1,1) = 1e-10;%Prevents divide by zero at 0 lp/deg
CSF_out(:,1) = CSF(1:1000:end,1);
CSF_out(:,2) = CSF(1:1000:end,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Calculate SQRI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Integrand = sqrt(CSF(:,2).*MTFInterp(:,2))./MTFInterp(:,1);
SQRI_Raw = (1/log(2))*abs(trapz(MTFInterp(2:end,1), Integrand(2:end)));
M_CR = Michelson_Contrast(DispLum, BackLum, DispCR, StackTrans);

SQRI_out = sqrt(M_CR).*SQRI_Raw;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end




