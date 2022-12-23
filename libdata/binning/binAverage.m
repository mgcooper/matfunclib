function binned = binAverage( data2bin, bindata, binwidth)
%BINAVERAGE Averages the value of data2bin in bins defined by bindata
%and the binwidth. Binwidth must be an even divisor of it's nearest power of 10.

%   INPUTS:
%   data2bin        =       the data that you want to average 
%   binData         =       the data that defines the bins
%   binwidth        =       the width of each bin

%   OUTPUTS:
%   binned.averages =       the average value of data2bin within each
%                           binwidth of bindata
%   binned.sdlow    =       binnedAverages - 1 standard deviation
%   binned.sdhigh   =       binnedAverages + 1 standard deviation
%   binned.members  =       data members within each bin
%   binned.bins     =       bin values

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
    averages(n)     =   nanmean(members{n});
    stdv                =   nanstd(members{n});
    SDlow(n)        =   averages(n) - stdv;
    SDhigh(n)       =   averages(n) + stdv;
end

binned.averages     =   averages;
binned.sdlow        =   SDlow;
binned.sdhigh       =   SDhigh;
binned.members      =   members;
binned.bins         =   bins;

