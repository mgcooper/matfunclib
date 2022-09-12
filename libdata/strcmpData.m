
for m = 1:length(listing)
    fname = listing(m).name;
    ind = find(data(:,1) == 0.1414);
    for n = 1:length(ind)
    get = ind(n);
    str1 = int2str(time(get,1:3));
    str2 = '1988    10     1';
    str3 = '1981     1     1';
    str4 = '1989    10     1';
    str5 = '1926    10    23';  
    if strcmp(str1,str2) == 1 || strcmp(str1,str3) == 1 || strcmp(str1,str4) == 1
    %sprintf('%s',int2str(time(get,1:3)))
	sprintf('%s',fname)
    end
    end
end

