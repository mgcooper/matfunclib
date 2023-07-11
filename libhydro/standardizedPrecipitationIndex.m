function [SPI, dist, q] = standardizedPrecipitationIndex(precip, dist, q)
%standardizedPrecipitationIndex Calculate standardized precipitation index (SPI)
%
% [SPI, dist, q] = standardizedPrecipitationIndex(precip, dist, q) computes the
% SPI from precipitation data from a given month using a gamma distribution. See
% McKee (1993) for details.
% 
% Inputs:
% 
% precip: precipitation for given month (can be aggregated over previous n months for longer time-scale SPI)
% (optional) dist: parameters of the gamma distribution
% (optional) q: probability of observing zero precipitation during month
% Outputs:
% 
% SPI: standardized precipitation index for the input month
% dist: parameters of the gamma distribution
% q: probabiliy of zero precipitation during input month
%
%
% https://climatedataguide.ucar.edu/climate-data/standardized-precipitation-index-spi
% 
% McKee, T. B., Doesken, N. J., & Kleist, J. (1993). The relationship of drought
% frequency and duration to time scales. In Preprints from the Eighth Conference
% on Applied Climatology (pp. 179�184). Anaheim, CA: American Meteorological
% Society.   
% 
% See also

if isempty(dist) | isempty(q)
   ind0 = find(precip == 0);
   PPT_noZeros = precip;
   PPT_noZeros(precip == 0 | isnan(precip)) = [];
   q = length(ind0) / length(precip(~isnan(precip)));

   dist = gamfit(PPT_noZeros);
   gs = gamcdf(precip, dist(1), dist(2));
   fs = q + (1-q)*gs;
   SPI = norminv(fs);
else
   gs = gamcdf(precip, dist(1), dist(2));
   fs = q + (1-q)*gs;
   SPI = norminv(fs);

end

end
