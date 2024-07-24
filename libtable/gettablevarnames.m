function varnames = gettablevarnames(tbl, typename)
   %GETTABLEVARNAMES Return tabular object VariableNames values as a cell array.
   %
   %  varnames = gettablevarnames(tbl)
   %  varnames = gettablevarnames(tbl, class)
   %
   % Description
   %  varnames = gettablevarnames(tbl) returns all values in the VariableNames
   %  propery of tabular object tbl.
   %  varnames = gettablevarnames(tbl, class) returns values in the
   %  VariableNames propery of tabular object tbl for variables of type CLASS.
   %  The VARTYPE function is used to find matching types.
   %
   % See also: gettableunits

   if nargin == 1
      % Return all variable names
      varnames = tbl.Properties.VariableNames;
      return
   end

   % Return by type
   varnames = gettablevarnames(tbl(:, vartype(typename)));

   % Legacy method
   % varnames = varnames(tablevartypeindices(T, typename));
end
