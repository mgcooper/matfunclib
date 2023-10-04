function T = rmfun(T)
   T.Properties.VariableNames=regexprep(T.Properties.VariableNames,'Fun_', '');
end