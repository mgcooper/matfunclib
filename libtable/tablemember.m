function T = tablemember(T, varname, member)
   %TABLEMEMBER Subset table rows by all members of group defined by variable.

   % Note: could rename to rowselect or similar
   T = T(ismember(T.(varname), member), :);
end
