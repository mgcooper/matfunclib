function S = renamestructfields(S, fields, newfields)
   %RENAMESTRUCTFIELDS Renames oldfields to newfields in struct S
   %
   %   S = RENAMESTRUCTFIELD(S, FIELDS, NEWFIELDS)
   %   S is the struct in which to rename the fields
   %   FIELDS are the names of the fields to rename
   %   NEWFIELDS are the names to rename FIELDS to
   %
   %   Copyright 2013-2014 The MathWorks, Inc.
   %
   %   mgc added the loop around multiple fields, reformatted for consistency
   %   with libstruct: renamed from renameStructField to renamestructfields,
   %   changed arguments 'struct', 'oldFieldNames', and 'newFieldNames' to 'S',
   %   'fields', and 'newfields'. added support for input char, string/array,

   if ischar(fields) || isstring(fields)
      fields = cellstr(fields);
   end

   if ischar(newfields) || isstring(newfields)
      newfields = cellstr(newfields);
   end


   for n = 1:numel(fields)
      oldFieldName = fields{n};
      newFieldName = newfields{n};

      if ~strcmp(oldFieldName, newFieldName)
         allNames = fieldnames(S);
         % Is the user renaming one field to be the name of another field?
         % Remember this.
         isOverwriting = ~isempty(find(strcmp(allNames, newFieldName), 1));
         matchingIndex = find(strcmp(allNames, oldFieldName));
         if ~isempty(matchingIndex)
            try
               allNames{matchingIndex(1)} = newFieldName;
               S.(newFieldName) = S.(oldFieldName);
               S = rmfield(S, oldFieldName);
            catch ME
               if contains(ME.identifier,'scalarStrucRequired')
                  msg = 'non-scalar struct array detected';
                  causeException = MException('MATLAB:renameStructField2',msg);
                  ME = addCause(ME,causeException);
               end

               tmp = S.(oldFieldName);
               if ~iscell(tmp)
                  [S.(newFieldName)] = S.(oldFieldName);
                  S = rmfield(S, oldFieldName);

               else
                  try
                     S.(newFieldName) = S.(oldFieldName);
                  catch ME
                     % need to test this
                  end
               end

            end

            if (~isOverwriting)
               % Do not attempt to reorder if we've reduced the number
               % of fields.  Bad things will result.  Let it go.
               S = orderfields(S, allNames);
            end
         end
      end
   end
end