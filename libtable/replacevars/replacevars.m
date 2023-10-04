function T = replacevars(T, VarNames, NewVars, varargin)
   %REPLACEVARS replace vars in table T with new vars.
   %
   % Syntax
   %
   %  T = REPLACEVARS(T,VarNames,NewVars) replaces columns with variable names
   %  VarNames with columns of NewVars. VarNames is a cell array of variable names
   %  that match values of T.Properties.VariableNames. NewVars is an array with
   %  second dimension (width) equal to numel(VarNames).
   %
   %  T = REPLACEVARS(T,VarNames,NewVars,'NewVarNames',NewVarNames) also replaces
   %  the VarNames with NewVarNames.
   %
   % Example
   %
   %
   % Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
   %
   % See also: addvars, removevars, renamevars, mergevars, movevars, splitvars,
   % convertvars

   % parse inputs
   [T, VarNames, NewVars, NewVarNames] = parseinputs(T, VarNames, ...
      NewVars, mfilename, varargin{:});

   % replace vars
   T = removevars(T,VarNames);
   V = gettablevarnames(T);
   V = [V NewVarNames];

   for n = 1:size(NewVars,2)
      T = addvars(T,NewVars(:,n));
   end
   T = settablevarnames(T,V);
end

function [T, VarNames, NewVars, NewVarNames] = parseinputs(T, VarNames, ...
      NewVars, funcname, varargin);

   p = inputParser;
   p.FunctionName = funcname;
   p.CaseSensitive = false;
   p.KeepUnmatched = true;

   validVarNames = @(x)all(ismember(x, gettablevarnames(T)));

   addRequired(p, 'T', @(x) istablelike(x) );
   addRequired(p, 'VarNames', validVarNames );
   addRequired(p, 'NewVars' );
   addParameter(p,'NewVarNames', VarNames, @(x) ischarlike(x) );

   parse(p,T,VarNames,NewVars,varargin{:});

   NewVarNames = p.Results.NewVarNames;
end
