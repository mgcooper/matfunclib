function config()
   %CONFIG configuration file template
   %
   %
   % See also:

   % use setenv here, setpref in setup.m

   % setenv(...)

   % temporarily turn off warnings about paths not already being on the path
   withwarnoff('MATLAB:rmpath:DirNotFound')

   % This is true if this function is called by the menv project manager toolbox
   % functions workon or configurepackage.
   if any(strcmp(mcallername(), {'workon', 'configureproject'}))

   end

   % This is true if running in desktop. Use it to suppress interactions with
   % editor such as opening or closing project files
   if usejava('desktop')

   end
end
