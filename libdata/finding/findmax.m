function [ maxinds,maxvals ] = findmax( indata,k,varargin )
%FINDMAX Returns the k indici(s) of the max value and the value at those
% indices. optional arguments follow those of 'max' e.g. 'first','last'
%   Detailed explanation goes here

if nargin == 1 % assume we want the first and only the first
   k        =  1;
   position =  'first';
else
   position =  varargin{:};
end

maxinds  =   find(indata == max(indata),k,position);

if isempty(maxinds); maxinds = nan; maxvals = nan; return; end

maxvals  =   indata(maxinds(:));

end

