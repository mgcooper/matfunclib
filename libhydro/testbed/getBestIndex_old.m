function [ bestIndex] = getBestIndex( data,min,max,inc,option )
%GETBESTINDEX getBestIndex finds the index(es) of the best parameter sets
%from a list of parameters and associated objective function scores. 
%   Available options include 'best' which returns only the highest scores,
%   or alternatively a user defined precision below the highest score that
%   returns all parameter sets above that value.

%   'DATA' = a numrunsx1 vector of objective function values e.g. NSE,
%   bias, rmse, or whatever you are trying to maximize

%   'MIN' = the minimum value of the objective function

%   'MAX' = the maximum value of the objective function

%   'INC' = the spacing of values between MIN and MAX i.e. the precision

%   'OPTION' = 'best' or a floating point input of user defined value.
%   'best' tells the function to return the indices with the highest value.
%   Alternatively, the user can define a precision below the highest value
%   and the function will return all indices above that value. For example,
%   if the highest score is 0.85, and the user supplies 0.02 for the
%   'option', the indices for all scores above 0.83 will be returned. 

[numsites,numruns] = size(data);

thresholds = min:inc:max;

A = zeros(numsites);
b = zeros(numsites); % initialize

for n = 1:length(thresholds);
    thresh = thresholds(n);
    b = A; % store this so we still have the index when length(A) = 0
    
    for m = 1:numsites
        a{m} = find(data(m,:) >=thresh);
    end
    
    
    % successively compare a{1} to a{2}..a{m}
    A = a{1};
    for m = 1:numel(a);
        A = intersect(A,a{m});
    end
    
    % If there's no intersection, then we've reached the maximum value that
    % is satisfied at all sites, which means the previous iteration (i.e.
    % thresholds (n-1) is the best score, and 'b' holds those indices from
    % the previous iteration
    
    if length(A) == 0
        bestscore = thresholds(n-1);
        bestIndex = b;
        break
    end
end

    
if strcmp(option,'best') == 1;
    bestIndex = bestIndex;
    
else % repeat the whole process for the new threshold

    newthresh = bestscore - option;

    for m = 1:numsites
        a{m} = find(data(m,:) >= newthresh);
    end

    % successively compare a{1} to a{2}..a{m} i.e. each site
    A = a{1};
    for m = 1:numel(a);
        A = intersect(A,a{m});
    end

    bestIndex = A;
end
%     
end
