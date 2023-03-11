function varargout = error_tricks(varargin)
%ERROR_TRICKS error tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% if i try to design an error analysis class / toolbox, below are resources
% to draw on:

% @meas class
% propUncert functions





