function [tf,vi] = isvariable(varname,T)
%ISVARIABLE determine if variable name is a variable in table T
arguments
   varname (:,1) string
   T (:,:) table
end
tf = any(strcmp(varname,T.Properties.VariableNames));
vi = find(strcmp(varname,T.Properties.VariableNames));

% tf = any(varname == string(T.Properties.VariableNames))