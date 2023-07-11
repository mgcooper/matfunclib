function N = figcount
%
% See also getopenfigs
h =  findobj('type','figure');
N = length(h);