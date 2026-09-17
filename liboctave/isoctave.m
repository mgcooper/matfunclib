function tf = isoctave()
   %ISOCTAVE Return logical true if the environment is Octave otherwise false.
   %
   %  tf = isoctave() returns true when the OCTAVE_VERSION builtin exists.
   %  A persistent variable caches the result to speed up repeated calls.
   %
   % See also: ishg2, isinteractive

   % Cache the result to speed up repeated calls.
   persistent cacheval;
   if isempty (cacheval)
      cacheval = (exist ("OCTAVE_VERSION", "builtin") > 0);
   end
   tf = cacheval;
end
