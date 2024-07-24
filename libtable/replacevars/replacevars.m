function tbl = replacevars(tbl, VarNames, NewVars, varargin)
   %REPLACEVARS replace vars in table with new vars.
   %
   %  tbl = replacevars(tbl, VarNames, NewVars)
   %  tbl = replacevars(tbl, VarNames, NewVars, NewVarNames=NewVarNames)
   %
   % Description
   %
   %  tbl = REPLACEVARS(tbl,VarNames,NewVars) replaces columns with variable
   %  names VarNames with columns of NewVars. VarNames is a cell array of
   %  variable names that match values of tbl.Properties.VariableNames. NewVars
   %  is an array with second dimension (width) equal to numel(VarNames).
   %
   %  tbl = REPLACEVARS(tbl,VarNames,NewVars,'NewVarNames',NewVarNames) also
   %  replaces the VarNames with NewVarNames.
   %
   % Example
   %
   %
   % Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
   %
   % See also: addvars, removevars, renamevars, mergevars, movevars, splitvars,
   % convertvars

   % parse inputs
   [tbl, VarNames, NewVars, NewVarNames] = parseinputs( ...
      tbl, VarNames, NewVars, mfilename, varargin{:});

   % replace vars
   tbl = removevars(tbl,VarNames);
   V = gettablevarnames(tbl);
   V = [V NewVarNames];

   for n = 1:size(NewVars,2)
      tbl = addvars(tbl,NewVars(:,n));
   end
   tbl = settablevarnames(tbl,V);
end

function [tbl, VarNames, NewVars, NewVarNames] = parseinputs(tbl, VarNames, ...
      NewVars, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   validVarNames = @(x)all(ismember(x, gettablevarnames(tbl)));

   addRequired(parser, 'tbl', @istabular);
   addRequired(parser, 'VarNames', validVarNames );
   addRequired(parser, 'NewVars' );
   addParameter(parser,'NewVarNames', VarNames, @ischarlike);

   parse(parser,tbl,VarNames,NewVars,varargin{:});

   NewVarNames = parser.Results.NewVarNames;
end
