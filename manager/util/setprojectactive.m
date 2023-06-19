function setprojectactive(projectname)
%SETPROJECTACTIVE set active project in project directory
% 
%  setprojectactive(projectname) sets the projectlist.activeproject attribute
%  true for the project specified by `projectname`.


projlist = readprjdirectory();
projlist.activeproject(1:end) = false;
projlist.activeproject(getprjidx(projectname)) = true;

writeprjdirectory(projlist);

% not sure if i want to go this route or not:
setenv('MATLAB_ACTIVE_PROJECT',projectname);
setenv('MATLAB_ACTIVE_PROJECT_PATH',fullfile(getprojectfolder(projectname)));
setenv('MATLAB_ACTIVE_PROJECT_DATA_PATH',fullfile(getprojectfolder(projectname),'data'));
setenv('MATLAB_ACTIVE_PROJECT_TESTBED_PATH',fullfile(getprojectfolder(projectname),'testbed'));


% % commented out, see setprojectfiles.
% if nargin == 1
%    projlist = readprjdirectory;
% end