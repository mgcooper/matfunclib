function T = settablevarnames(T,varnames,varargin)

opts = optionParser('consecutive',varargin);

% consecutive means varnames is a scalar string and the new varnames should be
% consecutive versions of that varname e.g. var1, var2, var3, ..., varN
if opts.consecutive == true && numel(string(varnames)) == 1
   varnames = strcat(varnames,string(1:numel(T.Properties.VariableNames)));
end
T.Properties.VariableNames = varnames;
