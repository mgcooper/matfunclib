function [obj, found] = renamefields(obj, oldnames, newnames)
   %RENAMEFIELDS Rename specified variables in a table or struct.
   %
   % Usage:
   %   obj = RENAMEFIELDS(obj, oldnames, newnames)
   %   obj = RENAMEFIELDS(obj, [], newnames)
   %   [obj, found] = RENAMEFIELDS(obj, oldnames, newnames)
   %
   % Description:
   %   This function renames variables specified by `oldnames` to `newnames`
   %   in the input object `obj`, which can be either a table or a struct. This
   %   function is similar to the standard renamevars (and undocumented
   %   renameStructField) but works with both struct and table. It deliberately
   %   mimics the function signature of those functions: (T, vars, newNames) and
   %   (str, oldFieldName, newFieldName), but allows the "oldnames" to be an
   %   empty object which means rename all fields (or table variables). In this
   %   case, the old names are retrieved automatically. Instead of modifying the
   %   function signature to make "oldnames" an optional third argument, the
   %   order was retained for consistency with renamevars.
   %
   % Inputs:
   %   obj      - The input object, which can be a table or a struct.
   %   oldnames - A cell array or string array of existing variable names. If
   %              empty, it is assumed all fields are to be renamed.
   %   newnames - A cell array or string array of new variable names
   %              corresponding to `oldnames`.
   %
   % Outputs:
   %   obj   - The modified object with variables renamed.
   %   found - A string array of the old variable names that were renamed.
   %
   % Example 1: Renaming fields in a struct
   %    s = struct('a', 1, 'b', 2, 'c', 3);
   %    [newStruct, found] = renamefields(s, ["a", "b"], ["alpha", "beta"]);
   %    disp(newStruct);
   %    disp(found);
   %
   % Example 2: Renaming variables in a table
   %    T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   %    [newTable, found] = renamefields(T, ["A", "B"], ["X", "Y"]);
   %    disp(newTable);
   %    disp(found);
   %
   % See also: renamevars renamestructfields rmvariables

   arguments
      obj
      oldnames (:, 1) string
      newnames (:, 1) string
   end

   % Special case: empty oldnames, assign all names.
   if isempty(oldnames)
      oldnames = parseFieldNames(obj);
   end

   % Check if the length of oldnames and newnames matches
   assert(numel(oldnames) == numel(newnames), ...
      ['custom:' mfilename ':mustBeOneNewNamePerOldName'], ...
      'The number of old names must match the number of new names.');

   wasstruct = isstruct(obj);
   wasscalar = isscalar(obj);

   if wasstruct
      obj = struct2table(obj, 'AsArray', true);
   end

   assert(istable(obj), ['custom:' mfilename ':inputMustBeStructOrTable'], ...
      'Input must be a struct or a table.');

   % Determine which of the old names are present in the object
   names = obj.Properties.VariableNames;
   [~, idxFound, idxNew] = intersect(names, oldnames);
   found = names(idxFound);

   % Rename variables
   obj.Properties.VariableNames(idxFound) = newnames(idxNew);

   if wasstruct
      obj = table2struct(obj, "ToScalar", wasscalar);
   end
end
