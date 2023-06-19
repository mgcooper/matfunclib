% function clean % clearvars seems to not work if this is a function
clearvars
close all hidden 
clc

% Make sure the workspace panel is showing. 
% Useful for undocked workspace configs.
% workspace
% commented out b/c when highlighting a script with clean at top it is annoying

% could use clarvars -except XXX if certain loaded vars are important, such as
% those defined on startup, like constants, but I don't currently do that

% home is similar to clc, but prior content still scrollable. puts the cursor in
% the top left of command window. 
% 
% Use home in a MATLAB® code file to always display output in the same starting
% position on the screen without clearing the Command Window.  
% 
% home

