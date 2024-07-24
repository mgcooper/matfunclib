function [names, found, extra, missing] = parseFieldNames(V, expected, kwargs)

   arguments(Input)
      V
      expected (1, :) string = string.empty(1, 0)
      kwargs.ExcludePropertyNames (1, 1) logical = true
   end
   arguments(Output)
      names (1, :) string
      found (1, :) string
      extra (1, :) string
      missing (1, :) string
   end

   [names, found, extra, missing] = deal(string.empty(1, 0));
   switch class(V)
      case 'struct'
         names = fieldnames(V);
      case 'table'
         if kwargs.ExcludePropertyNames
            names = V.Properties.VariableNames;
         else
            names = fieldnames(V);
         end
      otherwise
         % error('Unsupported InputClass: %s', InputClass);
         return
   end

   % Find names which are also in expected names. Does not depend on order.
   if ~isempty(expected)
      found = intersect(expected, names);
   else
      found = names;
   end

   % Find names which are not in expected names.
   if ~isempty(expected)
      extra = setdiff(names, expected);
   end

   % Find expected names which are not in names.
   missing = setdiff(expected, names);

   % To not use arguments
   % if nargin < 1
   %    expected = string.empty(1, 0);
   % end
end
