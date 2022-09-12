function [ starti, endi ] = dateInds_legacy(yri,moi,dayi,hri,yrf,mof,dayf,hrf,t)
%winterDates returns the start and end indices for 11/1 and 7/1 
%   Detailed explanation goes here

% startdate can be a 1xn datenumber e.g. [yri moi dayi hri] or a 1x1
% datenum vector, same for enddate
% t can be a nx7 time object created by timebuilder or a nx1 datenum vector

% t = time_builder(1998,10,1,1999,9,30,24);

if size(t,2)==1 % assume a single vector of datenums
    t   =   datevec(t);
end

starti  =   find(t(:,1) == yri & t(:,2) == moi & t(:,3) == dayi &...
                t(:,4) == hri, 1, 'first');
endi    =   find(t(:,1) == yrf & t(:,2) == mof & t(:,3) == dayf &...
                t(:,4) == hrf, 1, 'last');
    
    

end

