function varargout = functional_programming(varargin)
%MATLAB_TRICKS matlab tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

cd('/Users/coop558/mysource/matlab/functional/');
% activate 