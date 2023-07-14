function [ dif ] = percentDif( approximate,exact,varargin )
%PERCENTDIF compute the percent difference between approximate and exact data
%
% 
% 
% See also meanerror

narginchk(2, Inf)

dif = approximate - exact;
ssz = ones(size(dif)); ssz(isnan(dif)) = nan;
dif = 100.*sum(dif, varargin{:})./sum(ssz,varargin{:});

end

