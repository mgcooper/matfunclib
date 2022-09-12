function [ stats ] = getStats_NEW( obs,mod,window)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
[obsrows,obscols] = size(obs);
[modrows,modcols] = size(mod);

if obsrows ~= modrows
    error('numrows obs does not match numrows cols');
end

if nargin == 3
    
    if obsrows > obscols

        obs  =   nanmoving_average(obs,window,1,1);
        mod  =   nanmoving_average(mod,window,1,1);

    elseif obscols > obsrows

        obs  =   nanmoving_average(obs,window,2,1);
        mod  =   nanmoving_average(mod,window,2,1);
    end
end

stats.startobs      =   find(obs > 0,1,'first');
stats.startmod      =   find(mod > 0,1,'first');

stats.endobs        =   find(obs > 0,1,'last');
stats.endmod        =   find(mod > 0,1,'last');

stats.lengthobs     =   stats.endobs - stats.startobs;
stats.lengthmod     =   stats.endmod - stats.startmod;

stats.maxdateobs    =   find(max(obs) == obs,1,'last');
stats.maxdatemod    =   find(max(mod) == mod,1,'last');

stats.maxobs        =   obs(stats.maxdateobs);
stats.maxmod        =   mod(stats.maxdatemod);

stats.rateobs       =   stats.maxobs/(stats.endobs - stats.maxdateobs); 
stats.ratemod       =   stats.maxmod/(stats.endmod - stats.maxdatemod);

stats.maxperdif     =   100*(stats.maxmod - stats.maxobs)/stats.maxobs;
stats.maxdatedif    =   stats.maxdatemod - stats.maxdateobs;
stats.enddif        =   stats.endmod - stats.endobs;
stats.lengthdif     =   stats.lengthmod - stats.lengthobs;

stats.startdif      =   stats.startmod - stats.startobs;
stats.maxabsdif     =   stats.maxmod - stats.maxobs;
stats.rateperdif    =   100*(stats.ratemod - stats.rateobs)/stats.rateobs;  

end 