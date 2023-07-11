function strings = makeStringsChars(strings)

% note - might be enough to just cast to char in arguments block?
arguments
   strings (:,:) char
end

% arguments
%    strings (:,:) string
% end
% 
% chars = cellstr(numel(strings,1));
% 
% for iString = 1:numel(strings)
%    if isscalar(strings(iString))
%       % Convert scalar strings to char
%       chars{iString} = char(strings(iString));
%    else
%       % Convert string arrays to cell array of chars
%       chars{iString} = cellstr(strings(iString));
%    end
% end
% end