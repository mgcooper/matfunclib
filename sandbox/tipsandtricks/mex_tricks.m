function varargout = mex_tricks(varargin)
%MEX_TRICKS mex tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%% documentation

%% check current setup

mex -setup C % mex -setup is same as mex -setup C
mex -setup C++

% regarding the clipper2 installation, it says "building with clang++" but my c
% compiler is clang, not clang++ (clang++ is my c++ compiler)