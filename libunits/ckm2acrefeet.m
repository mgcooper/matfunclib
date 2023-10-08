function [ acre_feet ] = ckm2acrefeet( ckm )
   %CKM2ACREFEET Converts cubic kilometers to acre feet
   %   INPUT:      a vector or matrix of values in units of cubic kilometers
   %   OUTPUT:     a vector or matrics of values in units of acre feet
   acre_feet = ckm./810713.194;
end
