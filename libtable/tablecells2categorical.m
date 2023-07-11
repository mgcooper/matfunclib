function T = tablecells2categorical(T)

icells = cellfun(@iscell,table2cell(T(1,:)));
newvars = categorical(table2array(T(:,icells)));
varnames = T.Properties.VariableNames(icells);

for n = 1:numel(varnames)
   T.(varnames{n}) = newvars(:,n);
end