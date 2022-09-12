function struct = renameStructFields(struct, oldFieldNames, newFieldNames)
%RENAMESTRUCTFIELDS renames oldFieldName to newFieldName in struct str
%
%   STR = RENAMESTRUCTFIELD(STR, OLDFIELDNAME, NEWFIELDNAME)
%   STR is the struct in which to rename the field
%   OLDFIELDNAME is the name of the field to rename
%   NEWFIELDNAME is the name to rename OLDFIELDNAME to
%

%   mgc added the loop around multiple fieldnames

for n = 1:numel(oldFieldNames)
    oldFieldName = oldFieldNames{n};
    newFieldName = newFieldNames{n};

if ~strcmp(oldFieldName, newFieldName)
    allNames = fieldnames(struct);
    % Is the user renaming one field to be the name of another field?
    % Remember this.
    isOverwriting = ~isempty(find(strcmp(allNames, newFieldName), 1));
    matchingIndex = find(strcmp(allNames, oldFieldName));
    if ~isempty(matchingIndex)
        try
            allNames{matchingIndex(1)} = newFieldName;
            struct.(newFieldName) = struct.(oldFieldName);
            struct = rmfield(struct, oldFieldName);
        catch ME
            if contains(ME.identifier,'scalarStrucRequired')
                msg = 'non-scalar struct array detected';
                causeException = MException('MATLAB:renameStructField2',msg);
                ME = addCause(ME,causeException);
            end
            
            tmp = struct.(oldFieldName);
            if ~iscell(tmp)
                [struct.(newFieldName)] = struct.(oldFieldName);
                struct = rmfield(struct, oldFieldName);
                
            else
                try
                    struct.(newFieldName) = struct.(oldFieldName);
                catch ME
                   % need to test this 
                end
            end
            
        end
        
        if (~isOverwriting)
            % Do not attempt to reorder if we've reduced the number
            % of fields.  Bad things will result.  Let it go.
            struct = orderfields(struct, allNames);
        end
    end
end

end