% Was hopeful that function_handle would enable a generic function module, but I
% think it won't work if the function inputs are unknown. With validationModule,
% the more complicated case validOptionalArgument is constructed specially
% inside the validationModule subfunction. For generic functions, we would need
% to know the inputs, i think. But, the struct created below works and should be
% added to function_handle. 

p = '/Users/coop558/myprojects/icom-msd/project/toolbox/+pfa/private';
list = cellstr(getfilelist(p, '.m'));

F = function_handle(list);

% This works
F = cell2struct(F, cellfun(@func2str, F, 'uni', 0), 1);

% This fails
F = structfun(@(x, varargin) x(varargin), ...
   cell2struct(F, cellfun(@func2str, F, 'uni', 0), 1), 'uni', 0);

% Using varargin doesn't work either
F = structfun(@(x, varargin) x(varargin), ...
   cell2struct(F, cellfun(@func2str, F, 'uni', 0), 1), 'uni', 0);

vec = F.dealout(1:10);
[vec1, vec2] = F.dealout(1:10, 1:10);