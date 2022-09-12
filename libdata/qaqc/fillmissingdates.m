function [ data_new, dates_new, inds ] = fillmissingdates( data, dates, dt )
%FILLMISSINGDATES Finds missing dates in a timeseries of 'data' given a 
%vector 'time' of matlab formatted datenums and returns the filled data and
%indices 'inds' of missing data
%   Detailed explanation goes here

% Make sure the dates are datenums (could be a vector of years)
t           =   datenum(dates); 
y           =   data;

% dt          =   t(2) - t(1); doesn't work if the second value is missing

dates_new   =   (t(1):dt:t(end))';

% 3. Find the indexes of your times:
inds        =   round((t-t(1))/dt) + 1;

% 4. Generate the new data vector:
data_new    =   NaN(length(dates_new),1);

% 5. Insert the non NaN data into the new vector
data_new(inds)  =   y;

end

