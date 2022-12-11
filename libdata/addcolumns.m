function dataarray = addcolumns(dataarray,datacolumns,varargin)
%ADDCOLUMNS add columns to data array
% 
% 
% 
% See also

% NOTE: not sure why I don't use 'addvars' for type table. maybe I just spaced
% it, or maybe I did not finish that part of the code and it was just added to
% make the function more general, where dealing with arrays was the main goal

%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'addcolumns';
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

numcolumns  = size(datacolumns,2);
if ~isnan(index) && numel(index) ~= numcolumns
   error('numel(index) must match size(datacolumns,2)')
end

if ismatrix(dataarray)
   
   if isnan(index)
      dataarray = cat(2,dataarray,datacolumns);
   else
      dataarray(:,index) = datacolumns;
   end
   
elseif istable(dataarray)
   
   if istable(datacolumns)
      
      % get the current variable names of each table
      varnames1   = gettablevarnames(dataarray);
      varnames2   = gettablevarnames(datacolumns);
      
      % combine them and ensure they are unique
      newnames    = makeuniquevarnames([varnames1,varnames2]);
      newnames1   = newnames(1:numel(varnames1));
      newnames2   = newnames(numel(varnames1)+1:end);
      
      % reset the variable names of each table to the unique versions
      dataarray   = settablevarnames(dataarray,newnames1);
      datacolumns = settablevarnames(datacolumns,newnames2);
      
      % combine them
      dataarray   = [dataarray, datacolumns];

   else
      
      % this adds the columns to the table and uses the datacolumns
      % inputname (variable name in calling space) as the new table
      % variable names
      dataarray   = addvars(dataarray,datacolumns);
      
      % convert the table to an array
      % tabledata = table2array(dataarray);
   end
end