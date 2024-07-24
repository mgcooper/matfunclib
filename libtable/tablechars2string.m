function tbl = tablechars2string(tbl)
   %tablechars2string
   %
   %  tbl = tablechars2string(tbl)
   %
   % See also:

   ichar = find(tablevartypeindices(tbl,'char'));
   newvars = string(table2array(tbl(:,ichar)));
   varnames = tbl.Properties.VariableNames(ichar);

   for n = 1:numel(varnames)
      tbl.(varnames{n}) = newvars(:,n);
   end

   % This should work but has not been tested on multiple char vars
   % ichar = find(tablevartypeindices(tbl,'char'));
   % tbl.(tbl.Properties.VariableNames{ichar}) = string(tbl{:,ichar});

   % Another way to access the properties
   % charvars = tbl(1,vartype("char")).Properties.VariableNames

   % In one step
   % tbl.(string(tbl(1,vartype("char")).Properties.VariableNames)) = string(tbl{:, vartype('char')});
end
