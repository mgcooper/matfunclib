function [I, Lia, Locb] = intersectn(X, opts)
   %INTERSECTN Find common elements in multiple arrays.
   %
   % I = INTERSECTN(X1, X2)
   % [I, Lia, Locb] = INTERSECTN(X1, X2, ..., XN)
   % [I, Lia, Locb] = INTERSECTN(_, "WindowSize", W)
   % [I, Lia, Locb] = INTERSECTN(_, "ComparisonMethod", "all")
   %
   % Description:
   % The function INTERSECTN finds common elements among multiple input arrays
   % and optionally considers elements as common if they are within a specified
   % window. The function returns the common elements and indices of these
   % elements in the original arrays.
   %
   % ComparisonMethod "all":
   % Finds elements that are common to all input arrays, optionally within a
   % specified window size.
   %
   % ComparisonMethod "any":
   % Finds elements that are common to at least two arrays, optionally within
   % a specified window size.
   %
   % Inputs:
   % X - Cell array of input arrays.
   % opts - Struct with fields:
   %   ComparisonMethod: Either "any" or "all" (default "any").
   %   WindowSize: Scalar window size (default 0).
   %   ClosestMatch: Boolean flag to find closest match within WindowSize (default false).
   %
   % Outputs:
   % I - Array of common elements.
   % Lia - Cell array of logical vectors, indicating the presence of common
   %       elements in each input array.
   % Locb - Cell array of index vectors, indicating the indices of common
   %        elements in the output array I for each input array.
   %
   % See also: INTERSECT, UNIQUE, ISMEMBER

   arguments (Repeating)
      X (1, :)
   end
   arguments
      opts.ComparisonMethod string ...
         {mustBeMember(opts.ComparisonMethod, ["any", "all"])} = "any"
      opts.WindowSize (1, 1) double = 0
      opts.ClosestMatch (1, 1) logical = false
   end

   [W, X] = parseinputs(opts.WindowSize, X{:});

   N = numel(X);
   Lia = cell(1, N);
   Locb = cell(1, N);

   % Flatten all unique elements into a row vector.
   V = unique(cellflatten(X));
   V = V(:)';

   % Create masks for each X. Each mask is a row vector indicating if the
   % corresponding element of V is within the window of any element of x.
   inwindow = cellfun(@(x) any(abs(V - x(:)) <= W, 1), X, 'uni', false);

   switch opts.ComparisonMethod
      case "all"
         % Find common elements (the intersect) by summing down each column of
         % the stacked masks and checking if all are true, indicating the ith
         % element is common to all input arrays.
         I = V(sum(vertcat(inwindow{:}), 1) == N);

      case "any"
         % Find common elements (the intersect) by summing down each column of
         % the stacked masks and checking if one is true, after removing the
         % count contributed by the element itself.
         I = V(sum(vertcat(inwindow{:}), 1) - 1 >= 1);
   end

   if nargout > 1
      % Find the indices in each input array for the common elements.
      for n = 1:N
         [Lia{n}, Locb{n}] = ismember(X{n}, I);
      end

      % Confirm the indices are correct by extracting the values of each input
      % array and comparing them to the intersect.
      assertEqual(I, unique(cellflatten( ...
         arrayfun(@(n) X{n}(Lia{n}), 1:N, 'Uniform', false))));
   end
end

function [W, X] = parseinputs(W, varargin)
   % Check types and convert if necessary
   X = varargin;
   for n = 1:numel(X)
      if isdatetime(X{n})
         assert(isduration(W), ...
            'For datetime arrays, window size must be a duration.');
      elseif islogical(X{n})
         X{n} = find(X{n});
      elseif iscategorical(X{n})
         X{n} = cat2double(X{n});
      elseif ~isnumeric(X{n})
         error('intersectn:UnsupportedDataType', ...
            'INTERSECTN supports numeric, datetime, and categorical data types');
      end
   end
end


%{
   --------------
      Testing
   --------------

   % If no window is requested, a straightforward intersect can be used:

   if W == 0
      I = varargin{1};
      for n = 2:N
         I = intersect(I, varargin{n});
      end
      varargout{1} = I;
      for n=1:N
         [I, ~, varargout{n+1}] = intersect(I, varargin{n});
      end
      return
   end

% For reference, the entire "all" method can be done in one call, which may
   % be useful if function overhead is a concern and/or if matlab optimizes the
   % array expansions or other aspects of the operation:
   % I = cellflatten( cellfun(@(V) ...
   %    V(sum(cellflatten( cellfun(@(c) any(abs(V - c(:)) <= W, 1), ...
   %    varargin, 'Uniform', false), 1), 1) == numel(varargin)), ...
   %    {rowvec(unique(cellflatten(varargin)))}, 'Uniform', false) );

   This is relevent to intersectAny:
   I = intersect(unique(cellflatten(X)), unique(cellflatten(X) + (-W:W)));

   These are relevent to intersectAll

   I thought this was correct, but I think it is wrong b/c 

   % Create a mask for each array, indicating which elements are in the window
   % inwindow = cellfun(@(c) abs(elements - c(:)) <= W, varargin, 'uni', false);
   
   % Find common elements by summing the masks and checking if all are true
   % I = elements(sum(vertcat(inwindow{:}), 1) >= numel(varargin));



   % This is another way to get Icheck:
   % Icheck = cellfun(@(v, i) v(i), varargin, varargout(2:end), 'Uniform', false);

   % This returns the indices of the array elements in I, but I is unique so if
   % an array has multiple elements common to I, 
   % for n = 1:N
   %    [~, varargout{n+1}] = intersect(varargin{n}, I, 'stable');
   % end
   
   % % Create a mask for each array, indicating which elements are within the window
   % inwindow = cellfun(@(c) any(abs(elements - c(:)) <= W, 1), varargin, ...
   %    'uni', false);

   % % Find common elements by summing the masks and checking if all are true
   % I = elements(sum(vertcat(inwindow{:}), 1) == numel(varargin));


   inwindow{1}
   inwindow{2}
   inwindow{3}

   % I think this is more intuitive
   C = varargin(2:end);
   C0 = varargin{1};
   diffs = cellfun(@(c) abs(C0 - c.'), C, 'uni', false);
   inwindow = cellfun(@(c) abs(C0 - c.') <= W, C, 'uni', false);
   
   diffs{1}
   diffs{2}
   inwindow{1}
   inwindow{2}
   
   varargin{1} - varargin{2}'
   varargin{1} - varargin{3}'
   
   % each column of inwindow{1} represents all difference between one element of
   % varargin{1} and all elements of varargin{2}

   % each column of inwindow{2} represents all difference between one element of
   % varargin{1} and all elements of varargin{3}
   
   % the requirement is that each element of each array is within W of at least
   % one element of each other array
   
   % therefore it suffices to check whether each element of one array
   % (varargin{1}) meets the criteria, and since each column of the iwindow
   % arrays represents the differences, if at least one element is true
   
   % for each column of iwindow{n}, if any element is true for all n, it is a
   % "common element"
   
   % % % % % % % % % % % % % %    
   
   % This is the transpose of above. I think above is more intuitive because you
   % can do this:
   % varargin{1}
   % varargin{2}
   % and see the subtraction
     
   % C1 = C{1};
   % diffs = cellfun(@(c) c - C0, C, 'uni', false);
   % 
   % C1 - C0
   % d1 = diffs{1}
   
   % column i of d1 is the diff b/w element i of C{1} and all elements of C0
   % say: 
   % C1 = [1 2]
   % C0 = [1
   %       2
   %       1 ]
   % C1 - C0 = [ (1-1 =  0) (2-1 = 1)    = [ 0 1 ]
   %             (1-2 = -1) (2-2 = 0)       -1 0 
   %             (1-1 =  0) (2-1 = 1) ]      0 1 ];
   
   % therefore each element of column i that is <= W is a "common element" in
   % the sense that it is 
   
   C = varargin(2:end);
   C0 = varargin{1}.';
   inwindow = cellfun(@(c) abs(c - C0) <= W, C, 'uni', false);
   
   inwindow{1}
   inwindow{2}
   
   varargin{2} - varargin{1}'
   varargin{3} - varargin{1}'
   
   % each row of inwindow{1} represents all difference between one element of
   % varargin{1} and all elements of varargin{2}

   % each row of inwindow{2} represents all difference between one element of
   % varargin{1} and all elements of varargin{3}
   
   
   % for each column of inwindow, if any element going down the rows is <= W, it
   % means that element of varargin{1} is within W of 
%}
