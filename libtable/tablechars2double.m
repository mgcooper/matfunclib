function T = tablechars2double(T)

ichar = find(tablevartypeindices(T,'char'));

newvars = str2double(table2array(T(:,ichar)));
varnames = T.Properties.VariableNames(ichar);

for n = 1:numel(varnames)
   T.(varnames{n})   = newvars(:,n);
end

% Note: some other ways to access the table info
% charvars = T(1,vartype("char")).Properties.VariableNames

% ichar = cellfun(@ischar,table2cell(T(1,:)));
% T.(T.Properties.VariableNames{ichar}) = str2double(T{:, vartype('char')});


% old way, very slow
%    tf = cellfun(@isnumeric,table2cell(T(1,:)));
%    istr = find(~tf);
%    for n = 1:numel(istr)
%
%       T.(istr(n)) = str2double(T.(istr(n)));
%
%    end


end