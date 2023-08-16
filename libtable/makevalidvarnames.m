function varnames = makevalidvarnames(varnames)
%MAKEVALIDVARNAMES make variable names valid
%
% Example
% 
%  matlab.lang.makeValidName('test)1')
%  matlab.lang.makeValidName('test)1', 'ReplacementStyle', 'delete')
%  matlab.internal.tabular.makeValidVariableNames({'test)1'}, 'silent')
%  makevalidvarnames('test)1')
% 
% Using a cell array
%  matlab.internal.tabular.makeValidVariableNames('test)1', 'silent') % fails
%  matlab.lang.makeValidName({'test)1'}) % works
%  makevalidvarnames({'test)1'}) % works
%  
% 
% Updates
% 22 Feb 2023, replaced spaces with no space instead of underscores
% 
% See also: matlab.lang.makeValidName, matlab.lang.makeUniqueStrings,
% matlab.internal.tabular.makeValidVariableNames 

% NOTE: if a char array is passed in like:
% 'Var 1'
% 'Var10'
% 'Var11'
% 
% and I want to deblank the first one, it won't work, when it is cast to a
% cellstr below, the entire char array goes into one cell, and in the loop, the
% entire char array is pulled out on n=1

% if a cell array is passed in, we loop over it, but if a scalar string or char
% is passed in, we cast it to a cell array 
waschar = ischar(varnames);
wasstring = isstring(varnames);
if waschar || wasstring
   varnames = {varnames};
end

% make column
varnames = varnames(:);

% these are my preferred settings
for n = 1:numel(varnames)

   % remove leading/trailing blanks. replace in-between blanks with _
   varnames{n} = strtrim(varnames{n});
   %varnames{n} = strrep(varnames{n,:},' ','_');
   varnames{n} = strrep(varnames{n,:},' ',''); 
   varnames{n} = strrep(varnames{n,:},'_',''); 

   % use the built-in function, deleting invalid chars
   varnames{n} = matlab.lang.makeValidName(varnames{n},              ...
                  'ReplacementStyle','delete');
end

if numel(varnames) == 1
   if waschar; varnames = varnames{1}; end
   if wasstring; varnames = string(varnames{1}); end
end
% makeValidVariableNames uses the strtrim method used above