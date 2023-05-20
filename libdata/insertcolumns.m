function Data = addcolumns(Data,DataColumns,varargin)
%ADDCOLUMNS add columns to data array
% 
%  Data = addcolumns(Data,DataColumns) inserts (adds) columns to the end of Data
% 
%  Data = addcolumns(Data,DataColumns,ColumnIndices) inserts columns into
%  ColumnIndices
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also: 

% NOTE: not sure why I don't use 'addvars' for type table. maybe I just spaced
% it, or maybe I did not finish that part of the code and it was just added to
% make the function more general, where dealing with arrays was the main goal

%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

p.addRequired( 'dataarray',         @(x)isnumeric(x)|istable(x));
p.addRequired( 'datacolumns',       @(x)isnumeric(x)|istable(x));
p.addOptional( 'index',       nan,  @(x)isnumeric(x));

p.parseMagically('caller');

%-------------------------------------------------------------------------------

% use the variable inputname for the case of table data
% on second thought, if datacolumns is a table and 
% dataname = inputname(1);

% TODO: 
% - for multi-column datacolumns and table dataarray, add each column as a
% unique variable and append _X where X is a number to the variable name,
% and/or add an optional 'variablenames' input

numcolumns  = size(DataColumns,2);
if ~isnan(index) && numel(index) ~= numcolumns
   error('numel(index) must match size(datacolumns,2)')
end

if ismatrix(Data)
   
   if isnan(index)
      Data = cat(2,Data,DataColumns);
   else
      Data(:,index) = DataColumns;
   end
   
elseif istable(Data)
   
   if istable(DataColumns)
      
      % get the current variable names of each table
      varnames1   = gettablevarnames(Data);
      varnames2   = gettablevarnames(DataColumns);
      
      % combine them and ensure they are unique
      newnames    = makeuniquevarnames([varnames1,varnames2]);
      newnames1   = newnames(1:numel(varnames1));
      newnames2   = newnames(numel(varnames1)+1:end);
      
      % reset the variable names of each table to the unique versions
      Data   = settablevarnames(Data,newnames1);
      DataColumns = settablevarnames(DataColumns,newnames2);
      
      % combine them
      Data   = [Data, DataColumns];

   else
      
      % this adds the columns to the table and uses the datacolumns
      % inputname (variable name in calling space) as the new table
      % variable names
      Data   = addvars(Data,DataColumns);
      
      % convert the table to an array
      % tabledata = table2array(dataarray);
   end
end