function tbl = tablemember(tbl, varname, member)
   %TABLEMEMBER Subset table rows by all members of group defined by variable.
   %
   %  tbl = tablemember(tbl, varname, member)
   %
   % See also:

   % Note: could rename to rowselect or similar
   tbl = tbl(ismember(tbl.(varname), member), :);
end
