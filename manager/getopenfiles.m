function filenames = getopenfiles
%GETOPENFILES get a list of files currently open in the editor

if usejava('desktop')
   openfiles = transpose(matlab.desktop.editor.getAll);
   filenames = transpose({openfiles.Filename});
else
   warning("getopenfiles: editor is not open")
end

% to see all available methods:
% open matlab.desktop.editor.Contents 

% also see:
% /Applications/MATLAB_R2021b.app/toolbox/matlab/codetools