function T = tablecells2double(T)

   icells = find(tablevartypeindices(T,'cell'));
   newvars = str2double(table2array(T(:,icells)));
   varnames = T.Properties.VariableNames(icells);

   for n = 1:numel(varnames)
      T.(varnames{n}) = newvars(:,n);
   end
end
