function stats = binStats( data2bin, bindata, binwidth)
%BINSTATS Computs statistics from the values of data2bin in bins defined
%by bindata and the binwidth. Binwidth must be an even divisor of it's
%nearest power of 10.

%   INPUTS:
%   data2bin        =       the data that you want to average 
%   binData         =       the data that defines the bins
%   binwidth        =       the width of each bin

%   OUTPUTS:
%   stats.average   =       the average value of data2bin within each
%                           binwidth of bindata
%   stats.median    =       the average value of data2bin within each
%                           binwidth of bindata
%   stats.sdlow     =       binnedAverages - 1 standard deviation
%   stats.sdhigh    =       binnedAverages + 1 standard deviation
%   stats.members   =       data members within each bin
%   stats.bins      =       bin values

%   Example:

% data2bin is precipitation on a regular grid
% bindata is a digital elevation model of the regular grid, in meters
% binwidth is set to 100 (100-m)
% output is the average precipitation binned into 100-m elevation bands

% NOTE: data2bin and bindata must be same size!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the nearest power of 10 of the binwidth
r_n                 =   ceil(log10(binwidth));

% define the bins using the binwidth and the round_n value
minbin              =   min(bindata(:));
maxbin              =   max(bindata(:));
bins                =   roundn(minbin,r_n):binwidth:roundn(maxbin,r_n);
[bincounts, ind]    =   histc(bindata(:),bins);
numbins             =   length(bincounts);

for n = 1:numbins
    flagBinMembers  =   (ind == n);
    members{n}      =   data2bin(flagBinMembers);
    average(n)      =   nanmean(members{n});
    median(n)       =   nanmedian(members{n});
    stdv(n)         =   nanstd(members{n});
    SDlow(n)        =   average(n) - stdv(n);
    SDhigh(n)       =   average(n) + stdv(n);
end

stats.average       =   average;
stats.median        =   median;
stats.stdv          =   stdv;
stats.sdlow         =   SDlow;
stats.sdhigh        =   SDhigh;
stats.members       =   members;
stats.bins          =   bins;

end

