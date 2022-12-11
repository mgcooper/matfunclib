function member = tablemember(T,varname,value)

member = T(ismember(T.(varname),value),:);

member = T(contains(T.(varname),value),:);