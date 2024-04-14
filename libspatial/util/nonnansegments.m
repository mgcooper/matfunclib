function [S, E, L] = nonnansegments(x, nmin, option)
   %NONNANSEGMENTS Find start and end indices of complete non-nan segments.
   %
   % [S, E, L] = nonnansegments(x, nmin, option)
   %
   %  Inputs
   %     X - data. If X is a vector, S, E, L are returned as numeric arrays.
   %     If X is a matrix with >1 column, the algorithm operates on each column
   %     of X and returns S, E, L as cell arrays. If X is a cell array, the
   %     algorithm operates on each element, but currently assumes each element
   %     is a vector.
   %
   %     NMIN - minimum number of non-nan values to be returned as a valid
   %     segment (option not currently implemented - don't supply a value)
   %
   %     OPTION - 'any', 'each', 'all' (option not currently implemented  -
   %     don't supply a value)
   %
   % See also:

   if nargin < 3
      option = 'any'; % each?
   end
   if nargin < 2
      nmin = 1;
   end

   if iscell(x)
      % This case assumes each element of x is a vector.
      [S, E, L] = cellfun(@(x) processOneVector(x, nmin), x, 'Uniform', 0);
   else
      if isvector(x)
         [S, E, L] = processOneVector(x, nmin);

      elseif ismatrix(x)

         [S, E, L] = arrayfun(@(col) processOneVector(x(:, col), nmin), ...
            1:size(x, 2), 'Uniform', 0);

         % Identically:
         % for n = size(x, 2):-1:1
         %    [S{n}, E{n}, L{n}] = processOneVector(x(:, n), nmin);
         % end
      end
   end

   % TODO: if multiple vectors are passed in, return S, E where all vectors are
   % non-nan. Would also be good to allow multi-dimensional input e.g. in
   % fillplot, x and y are 1xN, but err is 2xN and I want S, E where all of them
   % are non-nan.
   switch option
      case 'all'
         % This is not right - need to know S and E for each all-nan segment.
         % Instead deal with this in the calling function.
         % S = unique(S);
         % E = unique(E);
      otherwise
   end

   % Notes on matrix-wise. First, the easiest way to reconcile the methods
   % above and support non-vector cell elements is to cast non-cell input to
   % cell and call cellfun for every case, and the subfuction it calls would
   % be processOneElement and would become the if else-if vector/matrix logic.

   % however, while adding vector/matrix logic, I tried two methods which need
   % to be documented here. First, if no distinction is made, then
   % processOneVector works fine with matrices, but it returns the linear
   % indices of all non-nansegments in a linear sense. Those can be converted
   % to row/col using ind2sub, or dealt with in the calling function. That will
   % create problems when the columns are independent samples and do not contain
   % identical start/stop ends because processOneVector will treat the entire
   % matrix in a linear sense thus "wrapping around" columns.

   % Second, initially to deal with that I looped over columns of X and did not
   % have an if-else, which works for both vectors and matrices but iff the
   % NUMBER OF start/stops are the same in each column.
   %
   % Thus finally I added the if-else and for matrix-wise I assign S, E to cell
   % arrays.

   % This is another way to deal with matrix-wise X, if no loop is used.
   % [row, col] = ind2sub(size(x), S)

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
