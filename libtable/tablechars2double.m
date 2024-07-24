function tbl = tablechars2double(tbl)
   %tablechars2double
   %
   %  tbl = tablechars2double(tbl)
   %
   % See also:

   ichar = find(tablevartypeindices(tbl,'char'));

   newvars = str2double(table2array(tbl(:,ichar)));
   varnames = tbl.Properties.VariableNames(ichar);

   for n = 1:numel(varnames)
      tbl.(varnames{n})   = newvars(:,n);
   end

   % Note: some other ways to access the table info
   % charvars = tbl(1,vartype("char")).Properties.VariableNames

   % ichar = cellfun(@ischar,table2cell(tbl(1,:)));
   % tbl.(tbl.Properties.VariableNames{ichar}) = str2double(tbl{:, vartype('char')});


   % old way, very slow
   %    tf = cellfun(@isnumeric,table2cell(tbl(1,:)));
   %    istr = find(~tf);
   %    for n = 1:numel(istr)
   %
   %       tbl.(istr(n)) = str2double(tbl.(istr(n)));
   %
   %    end
end
