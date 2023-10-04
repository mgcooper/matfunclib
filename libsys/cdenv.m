function cdenv(varargin)
   %CDENV cd to a path defined by an environment variable
   %
   %  cdenv(<tab complete>) brings up a list of current environment variables
   %  that contain PATH in their keyword definition then cd's to the selected
   %  value
   %
   %  cdenv(pathstring) changes to the directory specified by pathstr
   %
   %  cdenv() changes to the directory defined by the userpath env var
   %
   % Matt Cooper, 18-NOV-2022, https://github.com/mgcooper
   %
   % See also getuserpaths getenvall cdback cddata cdhome cdfunc

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   if nargin == 1
      requestedkey = varargin{1};
      [pathkeys, pathvals] = getuserpaths();
      ipath = ismember(pathkeys,requestedkey);
      cd(string(pathvals(ipath)));
   else
      cd(userpath);
   end
end
