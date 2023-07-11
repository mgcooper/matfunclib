function varargout = filter_tricks(varargin)
%FILTER_TRICKS filter tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% some functions to be aware of for data preprocessing:

% sgolayfilt
% filtfilt
% fillgaps
% intfilt
% filter


