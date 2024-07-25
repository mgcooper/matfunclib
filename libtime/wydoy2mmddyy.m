function [mm, dd, yyyy] = wydoy2mmddyy(numdays,t)
   %winterDates returns the start and end indices for 11/1 and 7/1
   %
   %  wydoy2mmddyy(numdays,t)
   %
   % See also

   % t = time_builder(1998,10,1,1999,9,30,24);
   yyyy = t(numdays,1);
   mm = t(numdays,2);
   dd = t(numdays,3);
end

