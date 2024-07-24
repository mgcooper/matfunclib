function tbl = tablechars2categorical(tbl)
   %tablechars2categorical
   %
   % tbl = tablechars2categorical(tbl)
   %
   % See also:

   ichar = find(tablevartypeindices(tbl,'char'));
   newvars = categorical(table2array(tbl(:,ichar)));
   varnames = tbl.Properties.VariableNames(ichar);

   for n = 1:numel(varnames)
      tbl.(varnames{n}) = newvars(:,n);
   end
end
