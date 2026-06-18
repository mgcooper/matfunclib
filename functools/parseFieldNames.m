function [names, found, extra, missing] = parseFieldNames(V, expected, kwargs)
   %PARSEFIELDNAMES
   %
   %  [names, found, extra, missing] = parseFieldNames(obj, expectedNames)
   %  [names, found, extra, missing] = parseFieldNames(names, expectedNames)
   %  [_] = parseVariables(_, ExcludePropertyNames=false)
   %
   % Inputs
   %  NAMES - a string or cellstr array of variable names.
   %  OBJ - an object with a names-like property (e.g., table or struct) for
   %  which the names can be retrieved with the FIELDNAMES function.
   %
   % Outputs
   %  NAMES - the input variable names or field/varnames present in OBJ.
   %  FOUND - names found in both NAMES and EXPECTEDNAMES.
   %  EXTRA - names present in NAMES which are not in EXPECTEDNAMES.
   %  MISSING - names present in EXPECTEDNAMES which are missing from NAMES.
   %
   % A cell is only a names array if it is a cellstr; a cell of data (e.g. a
   % multi-variable data input) has no names. Honor the documented "otherwise
   % empty names" contract instead of calling cellstr on non-text and erroring.
   %
   % See also

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
      case {'table', 'timetable'}
         if kwargs.ExcludePropertyNames
            names = V.Properties.VariableNames;
         else
            names = fieldnames(V);
         end
      case 'char'
         names = cellstr(V);
      case {'cell', 'string'}
         if iscellstr(V) || isstring(V)
            names = cellstr(V);
         end

      otherwise
         try
            names = fieldnames(V);
         catch e
            % rethrow(e)
            % error('Unsupported InputClass: %s', InputClass);
            return
         end
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
