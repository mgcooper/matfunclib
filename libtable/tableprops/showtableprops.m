function props = showtableprops(T)

   vars  = string(T.Properties.VariableNames);
   units = string(T.Properties.VariableUnits);

   props    = [vars;units]

   %    vars  = cellstr(T.Properties.VariableNames);
   %    units = string(T.Properties.VariableUnits);
   %
   %    props = table(units,'VariableNames',vars,'RowNames','units')
   %
   %    props = table([vars;units],'RowNames',{'vars','units'})
end
