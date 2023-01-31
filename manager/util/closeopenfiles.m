function closeopenfiles()
%CLOSEOPENFILES close all files open in the matlab editor
% 
%  closeopenfiles()
% 
% See also reopenfiles, reopentabs, openprojectfiles, reopentabs, savetabs
openDocuments = matlab.desktop.editor.getAll;
openDocuments.close;
