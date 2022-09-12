function [ wy_doy ] = wydoy( doy )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

start_date  =   datenum('10-01','mm-dd');
dum_date    =   start_date + doy;
wy_doy      =   datestr(dum_date,'mm-dd');

end

