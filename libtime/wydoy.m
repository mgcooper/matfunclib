function [wy_doy] = wydoy(doy)
   %WYDOY water year day of year from doy
   %
   %  [wy_doy] = wydoy(doy)
   %
   % See also:

   start_date = datenum('10-01','mm-dd');
   dum_date = start_date + doy;
   wy_doy = datestr(dum_date,'mm-dd');
end

