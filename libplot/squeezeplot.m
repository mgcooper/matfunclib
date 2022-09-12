function h = squeezeplot( data,varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

data    =   squeeze(data);

h = plot(data,varargin{:});


end

