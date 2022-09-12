function [ consec_vals ] = flagConsecutiveValues( data,tolerance )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

[rows,cols]     =   size(data);

if cols > rows
    data = data';
end

noc = cell(size(data));

for p = 1:cols
    
    for n = 2:rows
        dif     =   data(n,p) - data(n-1,p);      % get difference between consecutive values
        if dif == 0                    % check if it equals zero i.e. constant
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
        end
    end
end

for m = 1:cols
    
    for n = 1:rows

        consec_vals(n,m) = length(noc{n,m});
    end
end

consec_vals(1,:)        =   [];
consec_vals(end+1,:)    =   0;

inds = find(consec_vals == 2);

for n = 1:length(inds)
    consec_vals(inds+1) = 1;
end

inds = find(consec_vals > 0);


consec_vals     =   consec_vals + tolerance;






inds = find(consec_vals > 0);

for n = 1:length(inds)
    
    i   =   inds(n);
    
    if consec_vals(i - 1) < consec_vals(i)
        
        consec_vals(i - 1) = consec_vals(i);
        
    elseif consec_vals(i - 1) > consec_vals(i) & consec_vals(i) ~= 0
        
        consec_vals(i) = consec_vals;
    end
end


