function v = version()
   %GETVERSION Read version.txt in the toolbox root directory.
   %
   %  v = tbx.internal.version()
   %
   % See also:

   try
      v = fileread(projectpath(), 'version.txt');
   catch
      v = 'v0.1.0';
   end
end
