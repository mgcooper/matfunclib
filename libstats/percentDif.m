function [ dif ] = percentDif( approximate,exact )
%PERCENTDIF calculates the percent difference between an approximate
%dataset and the exact dataset
%   Detailed explanation goes here



dif = 100.*(nansum(approximate - exact))./nansum(exact);


end

