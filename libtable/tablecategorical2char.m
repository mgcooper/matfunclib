function tbl = tablecategorical2char(tbl)
   %TABLECATEGORICAL2CHAR convert categorical table variables to char
   %
   % tbl = tablecategorical2char(tbl)
   %
   % See also

   idx = vartype('categorical');
   newvars = tbl(:,idx);
   varnames = newvars.Properties.VariableNames;
   newvars = cellstr(table2array(newvars));

   for n = 1:numel(varnames)
      tbl.(varnames{n}) = newvars(:,n);
   end
end
