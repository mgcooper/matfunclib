function idx = tablevartypeindices(T,type)

%    % NOTE: built-in 'vartype' accomplishes this, e.g.:
%    bikeTbl  = readtable('BicycleCounts.csv');
%    bikeData = table2timetable(bikeTbl);
%    counts   =  bikeData{:,vartype('numeric')};
%    mean(counts,'omitnan')
   
   switch type
      
      case 'numeric'
   
         idx = cellfun(@isnumeric,table2cell(T(1,:)));
         
      case 'categorical'
         
         idx = cellfun(@iscategorical,table2cell(T(1,:)));
         
      case 'char'
         
         idx = cellfun(@ischar,table2cell(T(1,:)));
         
      case 'string'
         
         idx = cellfun(@isstring,table2cell(T(1,:)));
         
      case 'cell'
         
         idx = cellfun(@iscell,table2cell(T(1,:)));
         
      case 'notnumeric'
         
         idx = not(cellfun(@isnumeric,table2cell(T(1,:))));
         
   end