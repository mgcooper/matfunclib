function X = xgridvec(X)
%XGRIDVEC convert coordinates in X to grid vector
% 
%  X = XGRIDVEC(X) converts coordinates in X to grid vector
% 
% Example
%  
% 
% Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
% 
% See also gridvec, ygridvec

% input checks
narginchk(1,1)

X = reshape(sort(unique(X(:)),'ascend'),1,[]);