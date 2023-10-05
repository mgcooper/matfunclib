function S = makeStructFieldsChars(S)
   %MAKESTRUCTFIELDSCHARS Convert struct field values from strings to chars.
   %
   % S = makeStructFieldsChars(S)
   %
   % See also: char, string, convertStringsToChars
   
   fields = string(fieldnames(S));
   for iField = 1:numel(fields)
      if isstring(S.(fields(iField)))
         if isscalar(S.(fields(iField)))
            % Convert scalar strings to char
            S.(fields(iField)) = char(S.(fields(iField)));
         else
            % Convert string arrays to cell array of chars
            S.(fields(iField)) = cellstr(S.(fields(iField)));
         end
      end
   end
end
