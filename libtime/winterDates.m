function [starti endi] = winterDates
   %winterDates returns the start and end indices for 11/1 and 7/1

   t = time_builder(1998,10,1,1999,9,30,24);

   starti = find(t(:,2) == 11 & t(:,3) == 1);
   endi = find(t(:,2) == 7 & t(:,3) == 1);
end

