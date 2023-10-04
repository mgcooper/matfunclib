function Data = insertcolumns(Data, DataColumns, varargin)
%INSERTCOLUMNS insert columns into data array
%
%  Data = insertcolumns(Data,DataColumns) inserts columns to the end of Data
%
%  Data = insertcolumns(Data,DataColumns,ColumnIndices) inserts columns into
%  ColumnIndices
%
% Matt Cooper, 2022, https://github.com/mgcooper
%
% See also:

% NOTE: not sure why I don't use 'addvars' for type table. maybe I just spaced
% it, or maybe I did not finish that part of the code and it was just added to
% make the function more general, where dealing with arrays was the main goal

% parse inputs
[Data, DataColumns, ColumnIndices, ColumnVarNames] = parseinputs( ...
   Data, DataColumns, mfilename, varargin{:});

%% main code
% use the variable inputname for the case of table data
% on second thought, if datacolumns is a table and
% dataname = inputname(1);

% TODO:
% - for multi-column datacolumns and table dataarray, add each column as a
% unique variable and append _X where X is a number to the variable name,
% and/or add an optional 'variablenames' input

numColumns = size(DataColumns,2);
if ~isnan(ColumnIndices) && numel(ColumnIndices) ~= numColumns
   error('numel(ColumnIndices) must match size(DataColumns,2)')
end

if istable(Data)

   % get the variable names of the Data table
   % newNames = getNewNames(Data,DataColumns,ColumnVarNames);

   % get the variable names of the Data table
   varnames1 = gettablevarnames(Data);

   if istable(DataColumns)

      %
      if ~isempty(ColumnVarNames)
         % this is the case where we want new varnames, deal with this later
      end

      % get the variable names of the DataColumns table
      varnames2 = gettablevarnames(DataColumns);

      % combine them and ensure they are unique
      newNames = makeuniquevarnames([varnames1,varnames2]);
      newnames1 = newNames(1:numel(varnames1));
      newnames2 = newNames(numel(varnames1)+1:end);

      % reset the variable names of each table to the unique versions
      Data = settablevarnames(Data,newnames1);
      DataColumns = settablevarnames(DataColumns,newnames2);

      % combine them
      Data = [Data, DataColumns];

   else

      if isscalar(DataColumns)
         DataColumns = repmat(DataColumns,height(Data),1);
      end

      if isempty(ColumnVarNames)
         ColumnVarNames = "NewColumn";
      end
      
      for n = 1:numColumns
         Data = addvars(Data,DataColumns(:, n), ...
            'NewVariableNames', ColumnVarNames{n});
      end

      % convert the table to an array
      % tabledata = table2array(dataarray);
   end

elseif ismatrix(Data) % note that a column and a table are both a matrix in matlab

   if isscalar(DataColumns)
      DataColumns = repmat(DataColumns,height(Data),1);
   end

   if isnan(ColumnIndices)
      Data = cat(2,Data,DataColumns);
   else
      Data(:,ColumnIndices) = DataColumns;
   end

end

function newNames = getNewNames(Data,DataColumns,ColumnVarNames)

% didn't quite finish, but recall the order is important to get unique varnames,
% but to complete this to eliminate the need to store varnames1/2, would
% probably need to use cat(2,table2array(Data),table2array(DataColumns)) or do
% the [Data, DataColumns] then set VariableNames

% varnames1 = gettablevarnames(Data);

if istable(Data) && istable(DataColumns)

   % get the variable names of the DataColumns table
   %varnames2 = gettablevarnames(DataColumns);

   % combine them and ensure they are unique
   newnames = makeuniquevarnames([ ...
      gettablevarnames(Data),gettablevarnames(DataColumns)]);
   newnames1 = newnames(1:width(Data));
   newnames2 = newnames(width(Data)+1:end);
end

%% INPUT PARSER
function [Data, DataColumns, ColumnIndices, ColumnVarNames] = parseinputs( ...
   Data, DataColumns, mfilename, varargin)

f = validationModule;
parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.addRequired('Data', @(x) f.validTabular(x) | f.validNumericArray(x) );
parser.addRequired('DataColumns' );
parser.addOptional('ColumnIndices', nan, f.validNumericScalar );
parser.addParameter('ColumnVarNames', '', f.validCharLike );

parser.parse(Data, DataColumns, varargin{:}); clear f
ColumnVarNames = parser.Results.ColumnVarNames;
ColumnIndices = parser.Results.ColumnIndices;

%% LICENSE
% 
% BSD 3-Clause License
%
% Copyright (c) YYYY, Matt Cooper (mgcooper)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.