% Converts Matlab serial date to decimal year.
% Written by Mark Raleigh (mraleig1@uw.ed)
% 
%SYNTAX
% decyear = serial2dyear(serialdate)
%
%INPUT
%serialdate = 1x1 Matlab serial date value
%
%OUTPUT
%decyear = 1x1 decimal year value

function decyear = serial2dyear(serialdate)


%% Code

[yr, month, day, hr, minu, sec] = datevec(serialdate);

jday = greg2jul(yr, month, day, hr, minu);
jday=jday-1;

if rem(yr,4) == 0
    decyear = yr + (jday/366);
else
    decyear = yr + (jday/365);
end