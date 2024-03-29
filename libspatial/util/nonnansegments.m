function [S, E, L] = nonnansegments(x, nmin, option)
   %NONNANSEGMENTS Find start and end indices of complete non-nan segments.
   %
   % [S, E, L] = nonnansegments(x, nmin, option)
   %
   % See also:
   
   if nargin < 3
      option = 'any';
   end
   if nargin < 2
      nmin = 1;
   end

   if iscell(x)
      [S, E, L] = cellfun(@(x) processOneVector(x,nmin), x, 'Uniform', 0);
   else
      [S, E, L] = processOneVector(x, nmin);
   end
   
   % TODO: if multiple vectors are passed in, return S, E where all vectors are
   % non-nan. Would also be good to allow multi-dimensional input e.g. in
   % fillplot, x and y are 1xN, but err is 2xN and I want S, E where all of them
   % are non-nan.
   switch option
      case 'all'
      otherwise
   end
end

function [S, E, L] = processOneVector(x, ~)

   % Remove leading and trailing nan's.
   x = rmtrailingnans(x(:));
   [x, si] = rmleadingnans(x(:));
   
   % Find start and stop indices of non-nan segments.
   n = isnan(x(:));
   S = [1; find(diff(n) == -1) + 1];         % start non-nan segments
   E = [find(diff(n) == 1); numel(x)];       % end non-nan segments
   L = E - S + 1;                            % segment lengths

   % Adjust for the removal of leading nan's
   S = S + si - 1;
   E = E + si - 1;
    
   % Remove segments shorter than the minimum (option not implemented)
   % S = S(L >= nmin);
   % E = E(L >= nmin);
   % L = L(L >= nmin);
   
   % % I think this replaces the logic above and might be clearer, but it won't
   % capture leading/trailing nans either
   % ok = ~isnan(x);
   % S = find(diff([0, ok]) == 1);
   % E = find(diff([ok, 0]) == -1);
   
   % I think this works with leading and trailing nans
   % S = find(diff([NaN, x]) ~= 0 & ~isnan(x));
   % E = find(diff([x, NaN]) ~= 0 & ~isnan(x));
    
end

function [x, ei] = rmtrailingnans(x)
   %RMTRAILINGNANS Remove trailing nans.
   tf = flipud(logical(cumprod(isnan(flipud(x))))); % trailing nans
   ei = find(tf == false, 1, 'last'); % last non-nan indici
   x(tf) = [];
end

function [x, si] = rmleadingnans(x)
   %RMLEADINGNANS Remove leading nans.
   tf = logical(cumprod(isnan(x)));    % consecutive leading nans true
   si = find(tf==false, 1, 'first');   % first non-nan indici
   x(tf) = [];
end

% function [s, e] = startendnonnan(x)
%    n = isnan(x(:));
%    s = find(~n & [true; n(1:end-1)]);
%    e = find(~n & [n(2:end); true]);
%    
%    % [x(:) ~n [true; n(1:end-1)]] % starts
%    % [x(:) ~n [n(2:end); true]] % ends
% end
