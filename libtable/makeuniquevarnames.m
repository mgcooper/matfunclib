function varnames = makeuniquevarnames(varnames)
   %MAKEUNIQUEVARNAMES Make unique variable names for table or other object.
   %
   %  varnames = makeuniquevarnames(varnames)
   %
   % See also: mkvalidnames

   varnames = matlab.lang.makeUniqueStrings(varnames);
end
