function varnames = makevalidvarnames(varnames)

% NOTE: there is a built-in but unreported function makeValidVariableNames
% in /Applications/MATLAB_R2020b.app/toolbox/matlab/datatypes/tabular that
% is probably better than this one. it does both valid and unique, which i
% intentionally kept separate but may want to change, or make this a
% wrapper from makeValidVariableNames. At minimum do not rename this
% to makeValidVariableNames.

% if a cell array is passed in, we loop over it, but if a scalar string or char
% is passed in, we cast it to a cell array 
waschar = ischar(varnames);
wasstring = isstring(varnames);
if waschar || wasstring
   varnames = {varnames};
end

% these are my preferred settings
for n = 1:numel(varnames)

   % remove leading/trailing blanks. replace in-between blanks with _
   varnames{n} = strtrim(varnames{n});
   varnames{n} = strrep(varnames{n},' ','_');

   % use the built-in function, deleting invalid chars
   varnames{n} = matlab.lang.makeValidName(varnames{n},              ...
                  'ReplacementStyle','delete');
end

if numel(varnames) == 1
   if waschar; varnames = varnames{1}; end
   if wasstring; varnames = string(varnames{1}); end
end
% makeValidVariableNames uses the strtrim method used above