%RGB_XYZ_Matrices.m
%Generates RGB <--> XYZ Matrices from a given set of color primaries and
%white points

% M convertsRGB to XYZ
% M_inv converts XYZ to RGB
% From Wyszecki & Stiles

function [M_inv, M] = RGB_XYZ_Matrices(primaries, wp)
    xr = primaries(1,1); yr = primaries(1,2);
    xg = primaries(2,1); yg = primaries(2,2);
    xb = primaries(3,1); yb = primaries(3,2);
    
    xw = wp(1); yw = wp(2); 
    
    Y_w = 1;
    X_w = xw.*Y_w./yw;
    Z_w = (1-xw-yw)./yw;
    
    X_r = xr./yr; Y_r = 1; Z_r = (1-xr-yr)./yr;
    X_g = xg./yg; Y_g = 1; Z_g = (1-xg-yg)./yg;
    X_b = xb./yb; Y_b = 1; Z_b = (1-xb-yb)./yb;
    
    M_XYZ = [X_r, X_g, X_b; Y_r, Y_g, Y_b; Z_r, Z_g, Z_b];
    XYZ_w = [X_w;Y_w;Z_w];
    
    S = inv(M_XYZ)*XYZ_w; %Needs to be matrix multiply
    Sr = S(1); Sg = S(2); Sb = S(3);
    
    M = [Sr*X_r, Sg*X_g, Sb*X_b; Sr*Y_r, Sg*Y_g, Sb*Y_b; Sr*Z_r, Sg*Z_g, Sb*Z_b];
    M_inv = inv(M);
    M(abs(M)<1e-5) = 0;
end