function [ dataout ] = replacewithnan( data,value )
%REPLACEWITHNAN Replaces value with nan
%   Inputs:     data        =   vector or matrix of data
%               value       =   the value you want to replace with nan

%   Outputs:    dataout     =   'data' with 'value' replaced with 'nan'

inds            =   data == value;
data(inds)      =   nan;
dataout         =   data;
end

