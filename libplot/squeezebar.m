function h = squeezebar( data,varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

data    =   squeeze(data);

h = bar(data,varargin{:});


end

