function [ consec_vals ] = countConsecutiveValues( data, ignore_val )
%COUNTCONSECUTIVEVALUES locates constant consecutive values in a vector or
%matrix and returns the count of the number of consecutive values in the 
%indices of the consecutive values. The first value is ignored i.e. if a
%matrix contains 4 consecutive values e.g.:
%   example: 
%   data = [1 1 1 1; 2 1 3 3; 2 2 2 1];
%   data = [1 2 2; 1 1 2; 1 3 2; 1 3 1];
%   consec_values = countConsecutiveValues( data, []);
%   returned: [0 3 2 1; 0 0 0 1; 0 2 1 0];


%   Detailed explanation goes here

[rows,cols]     =   size(data);
noc             =   cell(rows,cols);
for p = 1:cols

    for n = 2:rows
            
        a = sum(data(n,p) == ignore_val);
        
        if a > 0
            noc{n,p}    =   NaN;
            continue
        end

        dif     =   data(n,p) - data(n-1,p);      % get difference between consecutive values
        if dif == 0                   % check if it equals zero i.e. constant
            noc{n,p} = [data(n,p) data(n-1,p)];     % 

            % check for additional consecutive values

            for m = n:(rows - n)

                dif = data(m+1,p) - data(m,p);

                if dif == 0

                    noc{n,p} = [noc{n,p} data(m+1,p)];

                elseif dif ~= 0

                    break

                end
            end
        else
            noc{n,p}    =   NaN;
        end
    end
end
    
consec_vals     =   NaN(size(data));

for m = 1:cols
    
    for n = 1:rows

        consec_vals(n,m) = length(noc{n,m}) - 1;
    end
end
% consec_vals = consec_vals';
consec_vals(consec_vals == -1) = 0;
end

