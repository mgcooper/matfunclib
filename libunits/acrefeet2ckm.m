function [ ckm ] = acrefeet2ckm( acre_feet )
   %CKM2ACREFEET Converts cubic kilometers to acre feet
   %   INPUT:      a vector or matrix of values in units of cubic kilometers
   %   OUTPUT:     a vector or matrics of values in units of acre feet

   ckm = acre_feet./810713.194;
end
