function varargout = numerical_tricks(varargin)
%NUMERICAL_TRICKS numerical tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% resources not to forget:

% uFVM - VERY AWESOME finite volume method toolbox, could even serve as a
% template for redesigning my entire approach to programming, using very
% explicit variable names, would require abandoning the screen width limit
% or lots of continuation lines but probably worth it in long run






