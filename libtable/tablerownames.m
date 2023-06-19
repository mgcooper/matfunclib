function rownames = tablerownames(T,ignoredrownames)
rownames = T.Properties.RowNames;
if nargin == 2
   rownames = rownames(~ismember(rownames,ignoredrownames));
end