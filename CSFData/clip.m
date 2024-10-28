function out = clip(in,lower,upper)

out = in;
out(out<lower) = lower;
out(out>upper) = upper;
