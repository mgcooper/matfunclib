function version = version(varargin)
   %GETVERSION read version.txt in the toolbox root directory
   %
   %  version = tbx.internal.version()
   %
   % See also:

   try
      version = fileread(tbx.internal.projectpath(), 'version.txt');
   catch
      version = 'v0.1.0';
   end
end
