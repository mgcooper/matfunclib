function [mm, dd] = doy2mmdd(doy, year)
   %DOY2MMDD Given the doy and the year, returns the mm and dd
   %
   %    [mm, dd] = doy2mmdd(doy, year)
   %
   %   Inputs:
   %               doy: DOY format
   %               year: YYYY format
   %
   %   Outputs:
   %               mm: MM format
   %               dd: DD format
   %
   %   Example:
   %               doy = 173;
   %               year = 2009;
   %               [mm,dd] = doy2mmdd(doy,year);
   %               [mm,dd] = doy2mmdd(doy,year)
   %
   %               mm =
   %
   %                  8
   %
   %               dd =
   %
   %                 17
   %
   %   Author: Matt Cooper
   %   Date: 3/13/2016
   %
   % See also

   % timebuilder(yri, monthi, dayi, hri, mini, yrf,monthf, dayf, hrf, minf, ...
   % timestep, varargin)

   t = timebuilder(year,1,1,0,0,year,12,31,0,0,24);
   mm = t(doy,2);
   dd = t(doy,3);
end

