function mhelp(cmd)
   %MHELP Display m-file help with more pager.
   %
   %  MHELP(FUNCNAME) displays help for mfile FUNCNAME.m using 'more on' paging.
   %  Press 'q' to exit.
   %  
   % Example
   %  mhelp('peaks')
   %  mhelp peaks
   %
   % Matt Cooper, 10-Feb-2023, https://github.com/mgcooper
   %
   % See also: help, more, home

   % input checks
   narginchk(0,1)

   cleanup = onCleanup(@()onCleanupFun());

   home
   more on
   help(cmd)
end

function onCleanupFun
   more off
end
