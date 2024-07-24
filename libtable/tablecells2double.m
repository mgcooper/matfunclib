function tbl = tablecells2double(tbl)
   %tablecells2double
   %
   %  tbl = tablecells2double(tbl)
   %
   % See also:

   icells = find(tablevartypeindices(tbl,'cell'));
   newvars = str2double(table2array(tbl(:,icells)));
   varnames = tbl.Properties.VariableNames(icells);

   for n = 1:numel(varnames)
      tbl.(varnames{n}) = newvars(:,n);
   end
end
