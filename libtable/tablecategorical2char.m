function T = tablecategorical2char(T)

%    % NOTE: built-in 'vartype' accomplishes this, e.g.:
%    bikeTbl  = readtable('BicycleCounts.csv');
%    bikeData = table2timetable(bikeTbl);
%    counts   =  bikeData{:,vartype('numeric')};
%    mean(counts,'omitnan')
   
   idx         =  vartype('categorical');
   newvars     =  T(:,idx);
   varnames    =  newvars.Properties.VariableNames;
   newvars     =  cellstr(table2array(newvars));

   for n = 1:numel(varnames)
      T.(varnames{n})   = newvars(:,n);
   end
   
end