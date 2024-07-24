function tbl = tablevarconvert(tbl,inputtype,outputtype,varargin)
   %TABLEVARCONVERT
   %
   %
   % See also

   % i did not finish this, not sure the best approach

   switch inputtype
      case 'numeric'
         idx = cellfun(@isnumeric,table2cell(tbl(1,:)));

      case 'categorical'
         idx = cellfun(@iscategorical,table2cell(tbl(1,:)));

      case 'char'
         idx = cellfun(@ischar,table2cell(tbl(1,:)));

      case 'string'
         idx = cellfun(@isstring,table2cell(tbl(1,:)));

      case 'cell'
         idx = cellfun(@iscell,table2cell(tbl(1,:)));

      case 'notnumeric'
         idx = not(cellfun(@isnumeric,table2cell(tbl(1,:))));
   end

   switch outputtype
      case 'numeric'
         idx = cellfun(@isnumeric,table2cell(tbl(1,:)));

      case 'categorical'
         idx = cellfun(@iscategorical,table2cell(tbl(1,:)));

      case 'char'
         tbl  = tablecategorical2char(tbl);

      case 'string'
         idx = cellfun(@isstring,table2cell(tbl(1,:)));

      case 'cell'
         idx = cellfun(@iscell,table2cell(tbl(1,:)));
      case 'notnumeric'
         idx = not(cellfun(@isnumeric,table2cell(tbl(1,:))));
   end
end
