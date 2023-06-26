function T = tablechars2string(T)

ichar = find(tablevartypeindices(T,'char'));
newvars = string(table2array(T(:,ichar)));
varnames = T.Properties.VariableNames(ichar);

for n = 1:numel(varnames)
   T.(varnames{n}) = newvars(:,n);
end

% This should work but has not been tested on multiple char vars
% ichar = find(tablevartypeindices(T,'char'));
% T.(T.Properties.VariableNames{ichar}) = string(T{:,ichar});

% Another way to access the properties
% charvars = T(1,vartype("char")).Properties.VariableNames

% In one step
% T.(string(T(1,vartype("char")).Properties.VariableNames)) = string(T{:, vartype('char')});

end