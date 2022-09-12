function [ norm_data ] = normdata( data,minout, maxout)
%NORMDATA simple normalization of data from 0 - 1
%   Detailed explanation goes here

if minout == 0 && maxout == 1
    
    mind        =   min(data);
    maxd        =   max(data);
    norm_data   =   (data - mind)./(maxd - mind);

elseif minout == -1 && maxout == 1
    
    factor      =   max([max(data) abs(min(data))]);
    norm_data   =   data/factor;

end

