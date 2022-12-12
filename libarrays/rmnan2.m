function [ data_out ] = rmnan2( data_in,dim )
%RMNAN removes NaN data

if nargin == 1
    bi                  =   isnan(data_in);
    data_in(bi)         =   [];
    data_out            =   data_in;
elseif nargin == 2  
    if dim == 1
        bi              =   isnan(data_in);
        data_in(bi)     =   [];
        data_out        =   data_in;
    elseif dim == 2
        bi              =   isnan(data_in);
        data_in(bi)     =   [];
        data_out        =   data_in;
    end
end
