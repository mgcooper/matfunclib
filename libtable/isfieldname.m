function [tf, name] = isfieldname(obj, fields)
   %isfieldname Check for specified field names in a struct or tabular object.
   %
   % Usage:
   %    [tf, name] = isfieldname(obj, fields)
   %
   % Inputs:
   %    obj - A struct, table, or timetable.
   %    fields - A char, string, or cell array of strings specifying field names
   %    to check.
   %
   % Outputs:
   %    tf - A logical array indicating whether each field name from 'fields' is
   %    found in 'obj'.
   %    name - A cell array of strings with the case-sensitive names of fields
   %    found.
   %
   % Example:
   %    S = struct('Name', 1, 'age', 25);
   %    [tf, name] = isfieldname(S, 'name'); % returns tf = true, name = {'Name'}
   %    if tf
   %        value = S.(name{1}); % Accessing the field using the case-sensitive name
   %    end
   %
   %    T = table(1,2,'VariableNames',{'id','Name'});
   %    [tf, name] = isfieldname(T, {'name', 'ID'});
   %    if any(tf)
   %        foundNames = T.(name{find(tf)}); % Accessing multiple fields
   %    end
   %
   % Note: This function treats "fieldnames" as equivalent to "VariableNames"
   % for tabular objects. This function does not check for the presence of
   % property names returned by fieldnames(tbl), where tbl is a tabular object.
   %
   % See also: isfield parseFieldNames

   % Convert fields to a string array for consistent handling
   fields = convertCharsToStrings(fields);

   assert(isstring(fields), ...
      'FIELDS must be a char, string, or cell array of strings.');

   % Initialize output variables
   tf = false(size(fields));
   name = cell(size(fields));

   % Retrieve variable names.
   if istable(obj) || istimetable(obj)
      varNames = string(obj.Properties.VariableNames);
   elseif isstruct(obj)
      varNames = string(fieldnames(obj));
   else
      return
      % error('Input must be a struct, table, or timetable.');
   end

   % Case insensitive comparison to find matching fields
   for n = 1:numel(fields)
      idx = find(strcmpi(fields(n), varNames), 1);
      if ~isempty(idx)
         tf(n) = true;
         name{n} = char(varNames(idx));
      end
   end

   % % Return as string
   % if kwargs.asstring
   %    name = string(name);
   % end
end
