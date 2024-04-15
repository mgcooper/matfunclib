function [dif, sumdif] = percentDif(approximate,exact,varargin)
   %PERCENTDIF Percent difference between approximate and exact data.
   %
   %  [dif] = percentDif(approximate, exact)
   %  [dif] = percentDif(approximate, exact, varargin) with varargin any input
   %  accepted by SUM.
   %  [_, sumdif] = percentDif(approximate, exact, varargin) also returns the
   %  percent dif of the sum over all elements.
   %
   % See also: meanerror

   narginchk(2, Inf)

   dif = approximate - exact;
   ssz = ones(size(dif)); ssz(isnan(dif)) = nan;
   dif = 100 * dif ./ ssz;
   sumdif = 100 * sum(dif, varargin{:})./sum(ssz,varargin{:});
end
