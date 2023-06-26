function T = tablecategorical2char(T)
%TABLECATEGORICAL2CHAR convert categorical table variables to char 
% 
% T = tablecategorical2char(T)
% 
% See also 

idx = vartype('categorical');
newvars = T(:,idx);
varnames = newvars.Properties.VariableNames;
newvars = cellstr(table2array(newvars));

for n = 1:numel(varnames)
   T.(varnames{n}) = newvars(:,n);
end

end