function prec = getnumprecision(x)

prec = ceil(log10(x));
prec(prec>0) = 0;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% below are notes from trendplot where prec is used to determine X in %.Xf
% sprintf statements for printing numbers, but here we want to determine whether
% to round: 
% prec = ceil(abs(log10(x)))+1;

% I think for any number > 1 we want to round to the zeroth place
% prec = log10(100)

% log10(x) = the number of zeros to right or left of decimal
% ceil(log10(x)) = ceil gets you to the digit e.g.:
% ceil(abs(log10(0.003))) = 3
% ceil(abs(log10(300))) = 3
% +1 gets you an extra digit of precision

% this is for printing an exponentinal:
% aexp = floor(log10(x));