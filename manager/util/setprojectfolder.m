function varargout = setprojectfolder(projectname,projectfolder,projectlist)
%SETPROJECTFOLDER set the activefolder property for a project
% 
%     projlist = setprojectfolder(projname,projfolder) sets the
%     projectlist.activefolder for project indicated by projname in the saved
%     project list directory to the provided projfolder.
% 
%     projlist = setprojectfolder(projname,projfolder,projlist) sets the
%     projectlist.activefolder for project indicated by projname in the project
%     list projlist to the provided projfolder.
% 
%     projlist = setprojectfolder(projectfolder) sets the activefolder attribute
%     of the current active project to projectfolder
% 
% Example
% 
%     % swap the project folder associated with 'interface' with the one
%     associated with 'E3SM-MOSART-offline-mode' b/c the code for 'interface' is
%     actually in 'E3SM-MOSART-offline-mode' folder
% 
%     setprojectfolder('interface',getprojectfolder('E3SM-MOSART-offline-mode'))
% 
%     When setprojectlinked is used to link two projects, the activefolder
%     attribute is set to the activefolder property of the linked project.
% 
%  NOTE: projectlist.folder is the parent folder, projectlist.activefolder is
%  the project folder
% 
% See also setprojectlinked

% Note: here is how to use this to update the active folder:
% setprojectfolder(getactiveproject,getprojectfolder('E3SM-MOSART-offline-mode'))
% the second argument is a backdoor way to get the path quickly for any project

if nargin < 3
   % assume the inputs are as defined on the function line
   projectlist = readprjdirectory;
   if nargin < 2
      % assume the input is projectfolder 
      if isfolder(projectname)
         projectfolder = projectname;
         projectname = getactiveproject();
      else
         error('expected input argument 1 to be a full-path projectfolder')
      end
   end
end
projindx = getprjidx(projectname,projectlist);

projectlist.activefolder{projindx} = projectfolder;

writeprjdirectory(projectlist);

if nargout == 1
   varargout{1} = projectlist;
end