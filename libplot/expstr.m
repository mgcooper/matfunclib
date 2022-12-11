function str = expstr(num)
%EXPSTR convert a number to a string of the form exp(x)
aexp = floor(log10(num));
str  = sprintf('$1e^{%.f}$',aexp);