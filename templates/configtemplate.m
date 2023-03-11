function Config()

% use setenv here, setpref in Setup

% use dbstack to get the file that called a function. For Config, might add a
% check that workon called it (or configurepackage) or it was called directly
% which might require checking mfilename('fullpath'), to rule out Config files
% in other packages. If called from the command window or terminal I'm not sure