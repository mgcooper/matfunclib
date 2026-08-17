function closeprojectunder(base)
   %CLOSEPROJECTUNDER Close the open Project if it is rooted under base.
   %
   %    closeprojectunder(base)
   %
   % Teardown helper shared by the manager Project suites. The teardown
   % runs whether or not the test opened a Project, so a missing or
   % already-closed Project must not raise.
   %
   % See also: testCreateMatlabProject, testProjectRefs

   arguments
      base (1,1) string
   end

   try
      proj = matlab.project.rootProject();
      if ~isempty(proj) && startsWith(string(proj.RootFolder), base)
         close(proj)
      end
   catch
      % No Project is open, which is the state the teardown wants.
   end
end
