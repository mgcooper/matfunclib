function tbl = rownames2var(tbl, kwargs)
   arguments
      tbl tabular
      kwargs.VariableName (1, :) char = 'RowLabels'
      kwargs.asnumeric (1, 1) logical = false
      kwargs.ascategorical (1, 1) logical = false
      kwargs.RemoveRowNames (1, 1) logical = true
   end

   newvar = tbl.Properties.RowNames;
   if kwargs.asnumeric
      newvar = str2double(newvar);
   end
   if kwargs.ascategorical
      newvar = reordercats(categorical(newvar), newvar);
   end

   tbl = addvars(tbl, newvar, 'NewVariableNames', kwargs.VariableName);
   if kwargs.RemoveRowNames
      tbl.Properties.RowNames = {};
   end
end
