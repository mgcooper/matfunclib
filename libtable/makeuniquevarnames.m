function varnames = makeuniquevarnames(varnames)
%MAKEUNIQUEVARNAMES make unique variable names for table or other object 
% 
%  varnames = makeuniquevarnames(varnames)
varnames = matlab.lang.makeUniqueStrings(varnames);