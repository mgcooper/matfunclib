function msg = mhelp(cmd)
%MHELP general description of function
% 
%  msg = MHELP(cmd) displays help using more on paging
% 
% Example
%  
% 
% Matt Cooper, 10-Feb-2023, https://github.com/mgcooper
% 
% See also

% input checks
narginchk(0,1)

cleanup = onCleanup(@()onCleanupFun());

more on
help(cmd)

function onCleanupFun
more off

