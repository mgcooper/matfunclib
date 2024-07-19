function fname = findgisfile(fname)
   %FINDGISFILE Location file in USERGISPATH.
   %
   % fname = findgisfile(fname)
   %
   % See also:

   % this is not a good approach. the reason i use addpath is because it makes
   % which work

   addpath(genpath(getenv('USERGISPATH')));

   % hack until I consolidate all GIS data in one location
   try
      addpath(genpath('/Users/coop558/work/data/icom/GIS/'))
   end

   fname = which(fname);
end
