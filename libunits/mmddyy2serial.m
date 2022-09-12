% Converts mmddyy numbers to Matlab Serial date
% Written by Mark Raleigh (mraleig1@uw.edu), July 2009
%
%SYNTAX
% sdates = mmddyy2serial(mmddyy, min_yr, max_yr)
% 
%INPUTS
% mmddyy = NxM matrix of mmddyy formatted dates
% min_yr = 1x1 value of earliest year (i.e. 1954)
% max_yr = 1x1 value of latest year (i.e. 2005)
%
% Note: min_yr and max_yr are necessary because there are only 2 numbers
% for year.  Thus, the code needs to disingush between 1911 and 2011 (both
% appear as yy = 11).
%
%OUTPUTS
% sdates = NxM matrix of Matlab serial dates
%
% NOTE: If this script receives a 5 digit value for the mmddyy, it assumes
% it is formatted as mddyy.

function sdates = mmddyy2serial(mmddyy, min_yr, max_yr)

%% Checks
if min_yr > max_yr
    error('min_yr must be less than or equal to max_yr')
end

if max_yr-min_yr >= 100
    error('Time span must be less than 100 yrs')
end



%% Code

N = size(mmddyy,1);
M = size(mmddyy,2);

sdates = zeros(N,M)*NaN;



for i=1:N
    for j=1:M
        current = num2str(mmddyy(i,j));
        if length(current)~=6 && length(current) ~=5
            disp(i)
            disp(j)
            mmddyy(i,j)
            disp(current)
            error('Invalid mmddyy date at the above coordinates')
        end
        
        if length(current)==6
            month = str2double(current(1:2));
            day = str2double(current(3:4));
            year = str2double(current(5:6));
        elseif length(current)==5
            month = str2double(current(1));
            day = str2double(current(2:3));
            year = str2double(current(4:5));
        end
        

        if (year+1900 >= min_yr) && (year+1900 < 2000) && (year+1900 <= max_yr)
            year = year + 1900;
        elseif (year+2000>=2000) && (year+2000 >= min_yr) && (year+2000 <= max_yr)
            year = year + 2000;
        else
            error('year went outside of limits. Adjust min_yr and/or max_yr')
        end

        sdates(i,j) = datenum(year,month,day);
    end
end
    


            
        
        