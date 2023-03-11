function varargout = path_tricks(varargin)
%PATH_TRICKS path tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% main issue is that pathdef.m can exist in matlabroot/toolbox/local but can
% also exist in userpath or any other location

% afaik, if savepath is called, userpath is set to ''. 

% default userpath by platform:

% Windows® platforms
%  %USERPROFILE%/Documents/MATLAB.

% Mac platforms 
% $home/Documents/MATLAB.

% Linux® platforms
%  $home/Documents/MATLAB if $home/Documents exists.


% If you use userpath('clear'), the startup folder will not necessarily be on
% the search path. This can also occur if you remove the userpath folder from
% the search path and save the changes.   


% need to understand what happens when savepath is used



