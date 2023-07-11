function Y = ygridvec(Y)
%YGRIDVEC convert coordinates in Y to grid vector
% 
%  Y = YGRIDVEC(Y) converts coordinates in Y to grid vector
% 
% Example
%  
% 
% Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
% 
% See also gridvec, xgridvec

% input checks
narginchk(1,1)

Y = reshape(sort(unique(Y(:)),'descend'),[],1);