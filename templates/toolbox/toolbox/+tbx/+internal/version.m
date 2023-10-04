function version = getversion(varargin)
%GETVERSION read version.txt in the toolbox root directory
% 
%  version = tbx.internal.getversion()
%
% See also:

try
   version = fileread(tbx.internal.projectpath(), 'version.txt');
catch
   version = 'v0.1.0';
end
