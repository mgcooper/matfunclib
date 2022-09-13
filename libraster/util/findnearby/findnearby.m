function [row,col,distance,idx] = findnearby(x,y,xq,yq,N)

% function [row,col,dist] = findnearby(x,y,xq,yq,N)
    
    %FINDNEAREST finds N nearest points to xq,yq within X,Y. Equivalent to
    %dsearchn for N=1. Locates a set of "nearby" points, rather than the
    %"nearest" points, which is what dsearchn returns.
    
    % Usage: 
    % [row,col] = findnearby(x,y,xq,yq,N)
    % idx       = findnearby(x,y,xq,yq,N)
    % [-,dist]  = findnearby(x,y,xq,yq,N) % use with any previous

    row     = nan(N,1);
    col     = nan(N,1);
    idx     = nan(N,1);
    dst     = nan(N,1);
    
    % keep the original size of the x,y coordinate arrays
    sizexy  = size(x);
    x       = x(:);
    y       = y(:);
    
    % we will exclude found points
    found   = false(size(x));
    
    % find N requested nearby points
    n = 0;
    while n<N
        
        n = n+1;
    
        [idx(n),dst(n)] =   dsearchn([x(~found) y(~found)],[xq yq]);
        [row(n),col(n)] =   ind2sub(sizexy,idx(n));

        % exclude the found point and repeat the search
        found(idx(n))   =   true;
    end
    
    distance = dst;
    
%     % package output
%     switch nargout
%         case 1
%             varargout       = idx;
%         case 2 % note: could be [idx, dist]
%             varargout{1}    = row;
%             varargout{2}    = col;
%         case 3
%             varargout{1}    = row;
%             varargout{2}    = col;
%             varargout{3}    = dist;
%     end
    
            