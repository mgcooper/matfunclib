function setprojectactive(projectname)
   %SETPROJECTACTIVE Set active project in project directory.
   %
   %  setprojectactive(projectname) sets the projectlist.activeproject attribute
   %  true for the project specified by `projectname`.
   %
   % See also: setprojectfiles

   projlist = readprjdirectory();
   projlist.activeproject(1:end) = false;
   projlist.activeproject(getprjidx(projectname)) = true;

   writeprjdirectory(projlist);

   % Canonical MATLAB_ACTIVE_* family: exactly this trio, matching the
   % template setupfile.m writer. These three have live readers (baseflow,
   % saltfront, libsys/cddata); the old _TESTBED_PATH variant had none and
   % was removed at the 2026 unification.
   setenv('MATLAB_ACTIVE_PROJECT',projectname);
   setenv('MATLAB_ACTIVE_PROJECT_PATH',fullfile(getprojectfolder(projectname)));
   setenv('MATLAB_ACTIVE_PROJECT_DATA_PATH',fullfile(getprojectfolder(projectname),'data'));

   % % commented out, see setprojectfiles.
   % if nargin == 1
   %    projlist = readprjdirectory;
   % end
end
