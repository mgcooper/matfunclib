function theStruct = makeStringsChars(theStruct)
    fields = string(fieldnames(theStruct));
    for iField = 1:numel(fields)
        if isstring(theStruct.(fields(iField)))
            if isscalar(theStruct.(fields(iField)))
                % Convert scalar strings to char
                theStruct.(fields(iField)) = char(theStruct.(fields(iField)));
            else
                % Convert string arrays to cell array of chars
                theStruct.(fields(iField)) = cellstr(theStruct.(fields(iField)));
            end
        end
    end
end