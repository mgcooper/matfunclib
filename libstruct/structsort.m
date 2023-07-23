function S = structsort(S,field,varargin)
%STRUCTSORT general description of function
% 
%  S = STRUCTSORT(S) sorts the rows of each matrix in S in ascending order based
%  on the elements in the first column. When the first column contains repeated
%  elements, sortrows sorts according to the values in the next column and
%  repeats this behavior for succeeding equal values.
% 
%  S = STRUCTSORT(S,'name1',value1) description
%  S = STRUCTSORT(S,'name1',value1,'name2',value2) description
%  S = STRUCTSORT(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 14-Feb-2023, https://github.com/mgcooper
% 
% See also

error('structsort is not functional')

% NOTE ON THE FUNCTIONSIGNATURES - I copied the ones from
% /Applications/MATLAB_R2021b.app/toolbox/matlab/datafun/sortrows.m 
% but which -all sortrows returns like eight versions and the one in @tabular is
% completely diffeent than the one I copied from datafun. The application was
% to sort all tables within a struct, where each table has the same varnames, to
% avoid looping over all tables in the struct. The main drawback is no tab
% complete for the varnames, since the struct could be full of tables with
% different varanmes. BUT, the way it works now, the tab complete options would
% apply to each element of S, so if each element of S were an array, then the
% current setup would work

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

validstrings      = {''}; % or [""]
validoption       = @(x)~isempty(validatestring(x,validstrings));

p.addRequired(    'S',                       @(x)isnumeric(x)     );
p.addRequired(    'field',       '',         @(x)ischarlike(x)    );

p.parseMagically('caller');

varargs = namedargs2cell(p.Unmatched);
%-------------------------------------------------------------------------------


if isscalar(S)
   % use structfun
   S = structfun(@(x) sortrows(x,field,direction),S,'uni',false);
else
   % use arrayfun
   S = arrayfun(@(x) sortrows(x,field,direction),S);
end













