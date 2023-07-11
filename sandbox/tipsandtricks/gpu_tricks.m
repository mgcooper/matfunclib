function varargout = gpu_tricks(varargin)
%GPU_TRICKS gpu tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% tells you if gpu stuff is possible, use programatically to avoid errors
canUseGPU

% see which gpus are avalilable
gpuDeviceCount("available")
gpuDeviceTable

