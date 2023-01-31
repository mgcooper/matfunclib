function filenames = getopenfiles
%GETOPENFILES get a list of files currently open in the editor
openfiles = transpose(matlab.desktop.editor.getAll);
filenames = transpose({openfiles.Filename});

% to see all available methods:
% open matlab.desktop.editor.Contents 

% also see:
% /Applications/MATLAB_R2021b.app/toolbox/matlab/codetools