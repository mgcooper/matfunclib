function T = tablevarconvert(T,inputtype,outputtype,varargin)
   %TABLEVARCONVERT
   %
   %
   % See also

   % i did not finish this, not sure the best approach

   p=magicParser;
   p.FunctionName=mfilename;
   p.addRequired('T',@(x)istable(x)||@(x)istimetable(x));
   p.addRequired('inputtype',@(x)ischar(x));
   p.addRequired('outputtype',@(x)ischar(x));
   p.parseMagically('caller');

   switch inputtype
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

   switch outputtype
      case 'numeric'
         idx = cellfun(@isnumeric,table2cell(T(1,:)));

      case 'categorical'
         idx = cellfun(@iscategorical,table2cell(T(1,:)));

      case 'char'
         T  = tablecategorical2char(T);

      case 'string'
         idx = cellfun(@isstring,table2cell(T(1,:)));

      case 'cell'
         idx = cellfun(@iscell,table2cell(T(1,:)));
      case 'notnumeric'
         idx = not(cellfun(@isnumeric,table2cell(T(1,:))));
   end
end