function [X,Y] = orientmapgrid(X,Y)

% if X is oriented W-E, orient it E-W
if X(1,1)~=min(X(:)) || X(1,2)<X(1,1)
   X = fliplr(X);
   disp(['Input argument 1, X, appears to be oriented E-W. It was ' ...
      're-oriented W-E, and the output of this function, R, assumes the ' ...
      'data referenced by R is oriented W-E.']);
end

% if Y is oriented S-N, orient it N-S
if Y(1,1)~=max(Y(:)) || Y(1,1)<Y(2,1)
   Y = flipud(Y);
   disp(['Input argument 2, Y, appears to be oriented S-N. It was ' ...
      're-oriented N-S, and the output of this function, R, assumes the ' ...
      'data referenced by R is oriented N-S.']);
end
