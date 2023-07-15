function [tf,vi] = isvariable(varname,T)
%ISVARIABLE determine if VARNAME is a variable in table T
% 
%  [TF, VI] = isvariable(VARNAME,T) returns TF = true if VARNAME is a variable
%  in table T, and the variable (column) index VI.
% 
% See also

arguments
   varname (:,1) string
   T (:,:) table
end
tf = any(strcmp(varname,T.Properties.VariableNames));
vi = find(strcmp(varname,T.Properties.VariableNames));

% tf = any(varname == string(T.Properties.VariableNames))