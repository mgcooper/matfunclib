function [mininds, minvals] = findglobalmin(Data, k, position, iref, varargin)
   %FINDGLOBALMIN Find the first k global min indices and values in data.
   %
   % optional arguments follow those of 'min' e.g. 'first','last'
   %
   %
   % See also: mink, findglobalmax

   narginchk(1,6)
   if nargin < 4, iref = 1; end
   if nargin < 3, position = 'first'; end
   if nargin < 2, k = 1; end

   % Find the indices of the min
   mininds = find(Data == min(Data, varargin{:}), k, position);

   if isempty(mininds)
      mininds = nan;
      minvals = nan;
      return
   end

   minvals = min(Data(mininds), varargin{:});
   mininds = find(Data == minvals, k, position);
   minvals = Data(mininds(:));

   % add iref to mininds. this supports cases where the data are passed in as
   % subsets of a larger dataset and we want to add iref to maxinds so maxinds are
   % relative to the start index of the larger dataset. assume that iref is the
   % indice of the first value in Data relative to the unknown larger dataset,
   % meaning we need to subtract 1, and default iref value is 1.
   mininds = mininds + iref - 1;
end
