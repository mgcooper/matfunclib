function tbl = tablecells2categorical(tbl)
   %tablecells2categorical
   %
   %  tbl = tablecells2categorical(tbl)
   %
   % See also

   icells = cellfun(@iscell,table2cell(tbl(1,:)));
   newvars = categorical(table2array(tbl(:,icells)));
   varnames = tbl.Properties.VariableNames(icells);

   for n = 1:numel(varnames)
      tbl.(varnames{n}) = newvars(:,n);
   end
end
