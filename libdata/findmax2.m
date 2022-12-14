function [maxval,maxinds] = findmax2( A, dim, direction )
%FINDMAX2  

if nargin < 2
   dim = 1 ;
end
if nargin < 3
   direction = 'f' ;
end
if direction(1) == 'f'
   [maxval, maxinds] = max( A, [], dim ) ;
else
   [maxval, maxinds] = max( flip( A, dim ), [], dim ) ;
   maxinds = size( A, dim ) + 1 - maxinds ;
end
