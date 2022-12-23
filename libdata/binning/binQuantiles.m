function [ binnedQuantiles ] = binQuantiles ...
                                ( data2bin, defineBinData, binwidth )
%BINAVERAGE Averages the value of data2bin in bins defined by defineBinData
%and the binwidth. Binwidth must be an even divisor of it's nearest power of 10.

%   INPUTS:
%   data2bin        =       the data that you want to average 
%   defineBinData   =       the data that defines the bins
%   binwidth        =       the width of each bin

%   OUTPUTS:
%   binnedAverages  =       the average value of data2bin within each
%                           binwidth of defineBinData
%   binnedSDlow     =       binnedAverages - 1 standard deviation
%   binnedSDhigh    =       binnedAverages + 1 standard deviation

%   Example:

% data2bin is precipitation on a regular grid
% defineBinData is a digital elevation model of the regular grid, in meters
% binwidth is set to 100 (100-m)
% output is the average precipitation binned into 100-m elevation bands

% NOTE: binAverage and defineBinData must be same size!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the nearest power of 10 of the binwidth
round_n           =       ceil(log10(binwidth));

% define the bins using the binwidth and the round_n value

binrange          =       roundn ...
    (min(defineBinData),round_n):binwidth:roundn(max(defineBinData),round_n);
[bincounts, ind]  =       histc(defineBinData,binrange);
numbins           =       length(bincounts);

for n = 1:numbins
    
    flagBinMembers      =   (ind == n);
    
    binMembers          =   data2bin(flagBinMembers);
    binMembers          =   rmnan(binMembers);
    
    binnedQuantiles(n,:)  =   quantile(binMembers,100); %#ok<AGROW>

end

