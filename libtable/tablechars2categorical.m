function T = tablechars2categorical(T)

   ichar = find(tablevartypeindices(T,'char'));
   newvars = categorical(table2array(T(:,ichar)));
   varnames = T.Properties.VariableNames(ichar);

   for n = 1:numel(varnames)
      T.(varnames{n}) = newvars(:,n);
   end
end
