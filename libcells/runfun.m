function runfun(fns)
   %RUNFUN Run all functions in a cell array, requesting no return values
   %
   % In Matlab this can be done with cellfun, but it's a bit messy and there are
   % compatibility problems with at least some versions of Octave.
   %
   % See also: dimfun

   % mgc renamed runfun
   for ii = 1:numel(fns)
      fns{ii}();
   end
end
