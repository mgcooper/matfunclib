function varargout = py_tricks(varargin)
%PY_TRICKS py tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% see this, which didn't come up after many many searches!!
% https://www.mathworks.com/help/matlab/matlab_external/passing-data-to-python.html

% https://www.mathworks.com/help/matlab/matlab_external/pythontuplevariables.html


plclass     = class(plaw);
plmethods   = methods(plaw);
plprops     = properties(plaw);
