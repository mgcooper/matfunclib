function [ km3 ] = mcm2km3( mcm )
   %MCM2ACREFEET Converts million cubic meters to acre feet
   %   INPUT:      a vector or matrix of values in units of million cubic
   %   meters
   %   OUTPUT:     a vector or matrics of values in units of acre feet

   km3 = mcm.*0.001;
end