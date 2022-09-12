function [ celtemp ] = fahr2cels( fahrtemp )
%FAHR2CELS converts fahrenheit temp to celsium
%   Detailed explanation goes here



celtemp = (fahrtemp - 32) .* (5/9);

end

