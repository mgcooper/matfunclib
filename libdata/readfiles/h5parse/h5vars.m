function vars = h5vars(fname)
%NCVARS extracts the variable names in a netcdf file
%   vars = ncvars(fname) is a wrapper for extractfield

%     Author: matt cooper (matt.cooper@pnnl.gov)

Info  =  h5info(fname);
vars  =  {Info.Groups.Name}';

end

