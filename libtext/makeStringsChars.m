function chars = makeStringsChars(strings)
   %MAKESTRINGSCHARS cast strings to chars
   %
   %  chars = makeStringsChars(strings)
   %
   %  Note: should probably abandon this in favor of convertStringsToChars, but
   %  this function enforces string input so may have a use case not addressed
   %  by that function which is designed for input parsing.
   %
   % See also: convertStringsToChars
   arguments
      strings (:,:) {mustBeA(strings, 'string')}
   end

   % This should suffice as long as the arguments block enforces string input
   if isStringScalar(strings)
      chars = char(strings);
   else
      chars = cellstr(strings);
   end
end
%% Alternative versions

% I think this syntax would work with no arguments block / casting to string or
% requiring string input. This might be preferable to the current version
% because this could be called instead of convertStringsToChars without needing
% the comma separated list syntax. However, if this is needed for argument
% passing where cell arrays are needed, then the isStringScalar block might need
% to cast to cellstr array.

% if isStringScalar(strings)
%    chars = char(strings);
% 
% elseif isstring(strings)
%    % Converts a string array to a cell array of char vectors.
%    chars = convertStringsToChars(strings);
% 
% elseif iscell(strings)
%    % Convert a cell array containing string arrays to a cell array of chars.
%    [chars{:}] = convertStringsToChars(strings{:});
% end

% This syntax requires nothing more than an argument block, but it casts any
% input that can be cast to a char e.g. makeStringsChars(1) returns ' '.
%
% function strings = makeStringsChars(strings)
%
% arguments
%    strings (:,:) char
% end

% NOTE: convertStringsToChars should be used in favor of the below syntax. This
% syntax places no requirement on the input therefore if a cell array is passed
% in, the elements of the cell array could be scalar strings, string arrays, or
% anything else, which is why the if-else deals with the non-scalar case using a
% loop rather than simply cellstr(strings) which would suffice if we knew that
% strings was either a scalar string or non-scalar string array.
%
% function chars = makeStringsChars(strings) %MAKESTRINGSCHARS cast strings to
% chars arguments
%    strings (:,:)
% end
%
% if isStringScalar(strings)
%    chars = char(strings);
%
% else
%    chars = cellstr(numel(strings,1));
%
%    for n = 1:numel(strings)
%       if isscalar(strings(n))
%          % Convert scalar strings to char array chars{n} = char(strings(n));
%       else
%          % Convert string arrays to cell array of chars chars{n} =
%          cellstr(strings(n));
%       end
%    end
%
% end
