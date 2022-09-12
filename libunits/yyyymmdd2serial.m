% Converts yyyymmdd numbers to Matlab Serial date
% 
%RELEASE NOTES
% Written by Mark Raleigh (mraleig1@uw.edu), January 2010
%
%SYNTAX
% sdates = yymmddhhmm2serial(yyyymmdd)
% 
%INPUTS
% yyyymmdd = NxM matrix of yyyymmdd formatted dates
%
%OUTPUTS
% sdates = NxM matrix of Matlab serial dates
%

function sdates = yyyymmdd2serial(yyyymmdd)


%% Code

N = size(yyyymmdd,1);
M = size(yyyymmdd,2);

sdates = zeros(N,M)*NaN;

for i=1:N
    for j=1:M
        current = num2str(yyyymmdd(i,j));
        
        if length(current)~=8
            disp(i)
            disp(j)
            yyyymmdd(i,j)
            disp(current)
            error('Invalid yyyymmdd date at the above coordinates')
        end
        
        year = str2double(current(1:4));
        month = str2double(current(5:6));
        day = str2double(current(7:8));

        sdates(i,j) = datenum(year,month,day);
    end
end
    

        