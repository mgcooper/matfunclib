function openprojectfiles(projectname)
%OPENPROJECTFILES open project files 

if nargin < 1
   projectname = getactiveproject();
end

activefiles = getprojectfiles(projectname);

% open the project files that are not already open
if ~isempty(activefiles)
   openfiles = getopenfiles();
   activefiles = activefiles(~ismember(activefiles,openfiles));
   reopenfiles(activefiles);

   % close all currently open files before reopening the project files
   % openfiles.close;
end

% % commented out see setprojectfiles
% if nargin == 1
%    projlist = readprjdirectory;
% end