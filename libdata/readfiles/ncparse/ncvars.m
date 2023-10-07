function vars = ncvars(fname)
   %NCVARS extracts the variable names in a netcdf file
   %
   %  vars = ncvars(fname) is a wrapper for extractfield
   %
   % See also: ncparse

   info = ncinfo(fname);
   vars = extractfield(info.Variables,'Name');
end
