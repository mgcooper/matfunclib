function [ mcm ] = acrefeet2mcm( acrefeet )
%ACREFEET2MCM Converts acre feet to million cubic meters 
%   INPUT:      a vector or matrix of values in units of acre feet
%   OUTPUT:     a vector or matrix of values in units of million cubic meters

mcm = acrefeet./810.71318210885;

