function T = tablecells2categorical(T)

%    % NOTE: built-in 'vartype' accomplishes this, e.g.:
%    bikeTbl  = readtable('BicycleCounts.csv');
%    bikeData = table2timetable(bikeTbl);
%    counts   =  bikeData{:,vartype('numeric')};
%    mean(counts,'omitnan')

inotnum     =  not(cellfun(@iscell,table2cell(T(1,:))));
newvars     =  categorical(table2array(T(:,inotnum)));
varnames    =  T.Properties.VariableNames(inotnum);

for n = 1:numel(varnames)
   T.(varnames{n})   = newvars(:,n);
end