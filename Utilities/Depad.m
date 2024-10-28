function [In] = Depad(In, Pad)

In(1:Pad, :, :)=[];
In(end-Pad+1:end, :, :)=[];
In(:, 1:Pad, :)=[];
In(:, end-Pad+1:end, :)=[];