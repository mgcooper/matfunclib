function Config()
%CONFIG config file template

% use setenv here, setpref in Setup

% setenv(...)

% temporarily turn off warnings about paths not already being on the path
withwarnoff('MATLAB:rmpath:DirNotFound')

if strcmp(mcallername(), 'workon') || strcmp(mcallername(), 'configurepackage')
   
end

% This is true if running in desktop. Use it to suppress interactions with
% editor such as opening or closing project files
if usejava('desktop')
   
end