function T = tablechars2double(T)

%    % NOTE: built-in 'vartype' accomplishes this, e.g.:
%    bikeTbl  = readtable('BicycleCounts.csv');
%    bikeData = table2timetable(bikeTbl);
%    counts   =  bikeData{:,vartype('numeric')};
%    mean(counts,'omitnan')


   ichar    = find(tablevartypeindices(T,'char'));

   newvars  = str2double(table2array(T(:,ichar)));
   varnames = T.Properties.VariableNames(ichar);

   for n = 1:numel(varnames)
      T.(varnames{n})   = newvars(:,n);
   end
   
% old way, very slow   
%    tf       = cellfun(@isnumeric,table2cell(T(1,:)));
%    istr     = find(~tf);
%    for n = 1:numel(istr)
% 
%       T.(istr(n)) = str2double(T.(istr(n)));
% 
%    end
   
   
end