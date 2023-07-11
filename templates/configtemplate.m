function Config()

% use setenv here, setpref in Setup

% temporarily turn off warnings about paths not already being on the path
withwarnoff('MATLAB:rmpath:DirNotFound')

% use dbstack to get the file that called a function. For Config, might add a
% check that workon called it (or configurepackage) or it was called directly
% which might require checking mfilename('fullpath'), to rule out Config files
% in other packages. If called from the command window or terminal I'm not sure

% This is true if running in desktop. Use it to suppress interactions with
% editor such as opening or closing project files
if usejava('desktop')
   
   
end