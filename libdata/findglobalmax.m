function [ maxinds,maxvals ] = findglobalmax( indata,k,varargin )
%FINDGLOBALMAX Returns the k indici(s) of the max value and the value at those
% indices. optional arguments follow those of 'max' e.g. 'first','last'
%   Detailed explanation goes here
% 
% RENAMED NOV 2022 TO AVOID CONFLICT WITH BUILT IN OPTIM/PRIVATE

if nargin == 1 % assume we want the first and only the first
   k = 1;
   position = 'first';
else
   position = varargin{:};
end

maxinds = find(indata == max(indata),k,position);

if isempty(maxinds); maxinds = nan; maxvals = nan; return; end

maxvals = indata(maxinds(:));

