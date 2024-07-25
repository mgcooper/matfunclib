function [mm, dd, yyyy] = doy2mmddyy(numdays, t)
   %doy2mmddyy returns the yyyy, mm, and dd numbers for a daily calendar
   %
   %  [mm, dd, yyyy] = doy2mmddyy(numdays, t)
   %
   % See also:

   % t = time_builder(1998,10,1,1999,9,30,24);
   yyyy = t(numdays,1);
   mm = t(numdays,2);
   dd = t(numdays,3);
end
