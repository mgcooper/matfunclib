function [t1, t2] = parsetimebounds(t1, t2, reftime)
   %PARSETIMEBOUNDS Parse lower and upper time bounds relative to reference time
   %
   %  [t1, t2] = parsetimebounds(t1, t2, reftime)
   %
   % Inputs
   %  t1 - the lower time bound
   %  t2 - the upper time bound
   %  reftime - a reference calendar in which t1 and t2 must fall
   %
   % The function ensures t1 is not prior to the earliest date in reftime, and
   % t2 is not later than the latest date. It then asserts t2>t1.
   %
   % See also:

   t1 = min(max(min(reftime), t1), max(reftime));
   t2 = max(min(max(reftime), t2), min(reftime));
   assert(t2 > t1)
end
