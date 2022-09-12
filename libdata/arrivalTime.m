function [ arrival_times ] = arrivalTime( X )
%ARRIVAL_TIME Computes inter-arrival time of binary events

arrival_times           =   nan(size(X));

for n = 1:length(X)
    bsdist_n            =   bwdist(X(n:end,1));
    arrival_times(n,1)  =   bsdist_n(1);
end

% set infinite values to nan (occurs if string of non-zeros at the end of
% the data, which means the next event is undefined
iinf                    =   isinf(arrival_times);
arrival_times(iinf)     =   nan;

% bwdist sets arrival years as zero distance, but we want the distance to
% the next arrival, so add 1 to the next year
izero                   =   find(arrival_times == 0);

% check if the last year turned up as zero
if izero(end) == length(X)
    izero(end) = [];
end

arrival_times(izero)    =   arrival_times(izero+1) + 1;

% set last year to nan, since next event is always undefined there
arrival_times(end,1)    =   nan;

end


