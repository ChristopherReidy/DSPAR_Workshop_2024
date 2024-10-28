function [M_CR] = Michelson_Contrast(DispLum, BackLum, DispCR, StackTrans)

Lmax = DispLum+BackLum*StackTrans;
Lmin = (DispLum/DispCR)+BackLum*StackTrans;
M_CR = (Lmax-Lmin)/(Lmax+Lmin);

end