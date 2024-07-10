function config(varargin)
   %CONFIG config file template

   % Note, use setenv here, setpref in Setup

   % Set environment variables
   % setenv(...)

   % Temporarily turn off warnings about paths not already being on the path
   withwarnoff('MATLAB:rmpath:DirNotFound')

   % Detect if this file is being called by menv/mproject
   if ismember(mcallername(), {'workon', 'configurepackage', 'setupfile'})

   end

   % This is true if running in desktop. Use it to suppress interactions with
   % editor such as opening or closing project files
   if usejava('desktop')

   end
end
