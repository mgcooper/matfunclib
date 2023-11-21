function varargout = findnearby(x,y,xq,yq,N)
   %FINDNEARBY find N nearest points in X,Y to M coordinate pairs Xq,Yq
   %
   % [ROW, COL] = findnearby(X,Y,Xq,Yq,N) returns NxM arrays ROW and COL, of row
   % and column indices for N coordinate pairs in X,Y nearest the M coordinate
   % pairs in Xq, Yq in euclidean space.
   %
   % [ROW, COL, DST] = findnearby(X,Y,Xq,Yq,N) also returns DST, an NxM array of
   % distances between each query point and its nearest point.
   %
   % [ROW, COL, DST, IDX] = findnearby(X,Y,Xq,Yq,N) also returns IDX, an NxM
   % array of linear indices for each nearest point in X,Y to each query point
   % in Xq,Yq.
   %
   % IDX = findnearby(X,Y,Xq,Yq,N) returns the linear index.
   %
   % Example
   % Xq, Yq are each 3x1 vectors representing 3 x-y coordinate pairs, then M =
   % 3. To find the 5 nearest points in X,Y to each of the 3 coordinate pairs in
   % Xq, Yq, set N = 5. The outputs ROW and COL will be 3x5 arrays representing
   % the indices in X,Y for the 5 nearest points in X,Y to the 3 query points in
   % Xq,Yq.
   %
   %
   % FINDNEARBY uses dsearchn to locate a set of "nearby" points, rather than
   % the "nearest" point, which is what dsearchn returns.
   %
   %
   % Matt Cooper @(c) 2021
   %
   % See also: dsearchn

   % I might have broken this by adding multiple points b/c the found thing
   % might remove them before they are found nearest the others

   if nargin == 4 || isempty(N)
      N = 1;
   end

   % Keep the original x,y array shapes, then reshape to column vectors
   wasvec = isvector(x) && isvector(y);
   sizexy = size(x);
   x = x(:);
   y = y(:);
   xq = xq(:);
   yq = yq(:);

   % Initialize the outputs
   M = numel(xq);
   row = nan(M, N);
   col = nan(M, N);
   idx = nan(M, N);
   dst = nan(M, N);

   % Use to exclude found points
   found = false(size(x));

   % find N requested nearby points
   n = 0;
   while n<N
      n = n+1;

      [idx(:, n), dst(:, n)] = dsearchn([x(~found) y(~found)], [xq yq]);
      [row(:, n), col(:, n)] = ind2sub(sizexy,idx(:, n));
      found(idx(:, n)) = true;
   end

   if wasvec
      assert(all(col(:) == 1))
   end
   % row = reshape(row, sizexy);
   % col = reshape(col, sizexy);

   % package output
   nargoutchk(1, 4)
   if nargout == 1
      varargout{1} = idx;
   else
      [varargout{1:nargout}] = dealout(row, col, dst, idx);
   end
end


% % This is the version before I added multi point support to debug
% function [row,col,distance,idx] = findnearby(x,y,xq,yq,N)
%    
%    row     = nan(N,1);
%    col     = nan(N,1);
%    idx     = nan(N,1);
%    dst     = nan(N,1);
% 
%    % keep the original size of the x,y coordinate arrays
%    sizexy  = size(x);
%    x       = x(:);
%    y       = y(:);
% 
%    % we will exclude found points
%    found   = false(size(x));
% 
%    % find N requested nearby points
%    n = 0;
%    while n<N
% 
%       n = n+1;
% 
%       [idx(n),dst(n)] =   dsearchn([x(~found) y(~found)],[xq yq]);
%       [row(n),col(n)] =   ind2sub(sizexy,idx(n));
% 
%       % exclude the found point and repeat the search
%       found(idx(n))   =   true;
%    end
% 
%    distance = dst;
% 
%    % package output
%    nargoutchk(1, 4)
%    if nargout == 1
%       varargout{1} = idx;
%    else
%       [varargout{1:nargout}] = dealout(row, col, dst, idx);
%    end
% end
