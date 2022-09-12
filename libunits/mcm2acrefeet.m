function [ acre_feet ] = mcm2acrefeet( mcm )
%MCM2ACREFEET Converts million cubic meters to acre feet
%   INPUT:      a vector or matrix of values in units of million cubic
%   meters
%   OUTPUT:     a vector or matrics of values in units of acre feet

acre_feet = mcm.*810.71318210885;


end

