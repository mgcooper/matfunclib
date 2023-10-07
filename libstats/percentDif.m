function [dif] = percentDif(approximate,exact,varargin)
   %PERCENTDIF Percent difference between approximate and exact data.
   %
   %  [dif] = percentDif(approximate,exact)
   %  [dif] = percentDif(approximate,exact,varargin) with varargin any input
   %  accepted by SUM.
   %
   % See also: meanerror

   narginchk(2, Inf)

   dif = approximate - exact;
   ssz = ones(size(dif)); ssz(isnan(dif)) = nan;
   dif = 100.*sum(dif, varargin{:})./sum(ssz,varargin{:});
end
