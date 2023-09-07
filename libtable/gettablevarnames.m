function varnames = gettablevarnames(T, typename)
   %GETTABLEVARNAMES Return table var names as a cell array.
   %
   %  varnames = gettablevarnames(T)
   %
   % See also: gettableunits

   varnames = T.Properties.VariableNames;

   if nargin == 1
      return
   end

   % otherwise, return by type
   varnames = gettablevarnames(T(:,vartype(typename)));

   % varnames = varnames(tablevartypeindices(T,typename));
end
