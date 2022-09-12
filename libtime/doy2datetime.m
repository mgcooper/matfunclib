function T = doy2datetime(doyvector,yearvector)
% DOY2DATE.m will convert a vector of day of year numbers and years
% and convert them to MATLAB date format. 
%  
% Sample Call: 
%  doyV = [54;200.4315];
%  yearV = [2009;2009];
%  [dateV] = doy2date(doyV,yearV);
%
% Inputs: 
%  doyV -> vector of day of year numbers (n x 1)
%  yearV -> vector of years (n x 1)
%
% Outputs: 
%  dateV -> vector of MATLAB dates (n x 1)
%
% AUTHOR    : A. Booth (ashley [at] boothfamily [dot] com)
% DATE      : 22-May-2009 09:34:53  
% Revision  : 1.00  
% DEVELOPED : 7.4.0.287 (R2007a) Windows XP 
% FILENAME  : doy2date.m 

%Check size of incoming vectors
if (size(doyvector,1)== 1) || (size(doyvector,2) == 1) %Make sure only a nx1 vector
    if size(doyvector,1)<size(doyvector,2)
        doyvector = doyvector';
        colflip = 1; %take note if the rows were flipped to col
    else
        colflip = 0;
    end
else %check to see that vectors are columns:
    error('DOY vector can not be a matrix')
end

%year vector
if (size(yearvector,1)== 1) || (size(yearvector,2) == 1) %Make sure only a nx1 vector
    if size(yearvector,1)<size(yearvector,2)
        yearvector = yearvector';
%         colflip = 1; %take note if the rows were flipped to col
    else
%         colflip = 0;
    end
else %check to see that vectors are columns:
    error('Year vector can not be a matrix')
end

%Check to make sure sizes of the vectors are the same
if ~min(size(doyvector) == size(yearvector))
    error('Day of year vector and year vector must be the same size')
end


%Make year into date vector
z = zeros(length(yearvector),5);
dv = horzcat(yearvector,z);

%Calc matlab date
T = doyvector + datenum(dv);

% flip output if input was flipped
if colflip
    T = T';
end

T = datetime(T,'ConvertFrom','datenum');


% disp('Completed doy2date.m') 
% ===== EOF [doy2date.m] ======  
