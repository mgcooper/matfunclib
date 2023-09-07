function varargout = demo_intersectn(W, varargin)
   %DEMO_INTERSECTN Demonstrate the intersectn algorithm
   
   %% The actual implementation
   
   N = numel(varargin);
   varargout = cell(1, N+1);
   
   % Flatten all unique elements into a row vector
   elements = unique(cellflatten(varargin));
   elements = elements(:)';

   % Create a mask for each array, indicating which elements are within the window
   inwindow = cellfun(@(c) ...
      any(abs(elements - c(:)) <= W, 1), varargin, 'uni', false);
   
   % Find common elements by summing the masks and checking if all are true
   I = elements(sum(vertcat(inwindow{:}), 1) == numel(varargin));
   
   varargout{1} = I;
   
   % Use rowvec and cellflatten to stack the inwindow arrays and sum in one step
   V = rowvec(unique(cellflatten(varargin)));
   I = V(sum(cellflatten(cellfun(@(c) any(abs(V - c(:)) <= W, 1), ...
      varargin, 'uni', false), 1), 1) == numel(varargin));
   
   I = cellfun(@(V) V(sum(cellflatten(cellfun(@(c) any(abs(V - c(:)) <= W, 1), ...
      varargin, 'uni', false), 1), 1) == numel(varargin)), ...
      {rowvec(unique(cellflatten(varargin)))});
   
   % So the entire function could be:
   
   inwindow = cellfun(@(c) any(abs(elements - c(:)) <= W, 1), varargin, 'uni', false);
   I = elements(sum(vertcat(inwindow{:}), 1) == numel(varargin));
   
   % An alternative to "any" is to sum and apply min(1, ...) but any is 
   % clearly simpler 
   %    minsum = 1;
   %    dimsum = 1;
   %    inwindow = cellfun(@(c) ...
   %       min(sum(abs(elements - c(:)) <= W, dimsum), minsum), varargin, 'uni', 0);
   
   %% Deconstruct components 
   
   diffs = cellfun(@(c) elements - c(:), varargin, 'uni', false);
   absdiffs = cellfun(@(c) abs(elements - c(:)), varargin, 'uni', false);
   inwindow = cellfun(@(c) abs(elements - c(:)) <= W, varargin, 'uni', false);
   anyinwin = cellfun(@(c) any(abs(elements - c(:)) <= W), varargin, 'uni', false);
   anyinwin1 = cellfun(@(c) any(abs(elements - c(:)) <= W, 1), varargin, 'uni', false);
   catinwindow = cat(1, inwindow{:});
   catanyinwin = cat(1, anyinwin1{:});

   % Each row of absdiffs is the diff between all unique elements and the
   % elements of one array i.e. absdiffs{1} is the diffs for varargin{1}.
   % Therefore, for the ith unique element, the ith column of the jth absdiffs
   % array is the diffs between the ith unique element and each element of the
   % jth array. The requirement is that the ith unique element is within the
   % window of at least one element in all arrays, so if any value in the jth
   % column is true, the requirement is met for the jth array. By applying any,
   % we guarantee that only ONE logical true exists for the ith element - jth
   % array comparison, yielding one row of logicals for each array. The catinwin
   % step stacks those rows into a N x M array of N rows, one for each array,
   % and M columns, one for each unique element. If the sum down the Mth column
   % equals N, then the requirement is satisied for all arrays. NOTE: if "any"
   % is ommitted, then incorrect results occur if the ith element is within the
   % window of more than one element of the jth array, which will always occur
   % if it is within the window of any other element in its own array since it
   % is within the window of itself. When "any" is applied, this is not a
   % problem, in fact it is a requirement otherwise the element would be deemed
   % missing from one array (it's own). For the "intersectAny" method, however,
   % applying "any" is problematic for this reason, b/c we need the element to
   % be present (or within the window) of at least one element in at least one
   % OTHER array. 
   i = numel(elements); % 
   j = 1;

   ielem = elements(i); % the i'th element
   absdiffs{j}(:, i) % abs(ielem - varargin{j}.')
   inwindow{j}(:, i) % abs(ielem - varargin{j}.') <= W
   any(inwindow{j}(:, i), 1) % any(abs(ielem - varargin{j}.') <= W, 1)
   % if any is true, then the requirement is met for the jth array
   
   elements
   varargin{j}(:)
   % diffs{j}
   absdiffs{j}
   inwindow{j}
   anyinwin{j}
   anyinwin1{j}
   
   %% "any" method
   
   % 
   commonCounts = sum(vertcat(inwindow{:}), 1) - 1;
   
   
   inwindow = cellfun(@(c) abs(elements - c(:)) <= W, varargin, 'uni', false);
   
   I = elements(sum(vertcat(inwindow{:}), 1) >= numel(varargin));
   
   
end