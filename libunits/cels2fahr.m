function [ fahrtemp ] = cels2fahr( celstemp )
   %FAHR2CELS converts fahrenheit temp to celsium
   fahrtemp = (celstemp + 32) ./ (5/9);
end
