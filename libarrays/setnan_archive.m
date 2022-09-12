function [ data_out ] = setnan_archive( data_in,inds )
%RMINDS sets logical indices in data to nan
%   Updated to use a nan value instead of the indices

data_out        =   data_in;
data_out(inds)  =   nan;

end

