function uifigontop(fighandle)
%  WINDOWONTOP({FIGHANDLE})
%    Set a window to be always on top using external tools.
%    This relies on the use of wmctrl.  If you don't have it
%    then you'll have to install it.  This won't work in Windows.
%  
%  FIGHANDLE is a figure handle
%    if none is provided, gcf is used
%
%  See also: maximizewindow

if nargin == 0
	fighandle = gcf;
end

windowname = 'floaty_matlab_figure';

% temporarily assert a new window name so that wmctrl can find it
origwinname = get(fighandle,'name');
orignumtitle = get(fighandle,'numbertitle');
set(fighandle,'numbertitle','off','name',windowname);

pause(1); % gotta wait for wm
system(sprintf('winid=$(wmctrl -lx | grep "%s" | cut -d \\  -f 1 | tail -n 1); wmctrl -ir "$winid" -b add,above',windowname));

% revert window name
set(fighandle,'numbertitle',orignumtitle,'name',origwinname);



