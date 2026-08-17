function closetestproject(root)
   %CLOSETESTPROJECT Close the open Project if it is rooted under root.
   %
   %    closetestproject(root)
   %
   % Teardown helper shared by the template build suites. The teardown
   % runs whether or not the test opened a Project, so a missing or
   % already-closed Project must not raise.
   %
   % See also: testReleaseOptions, testBuildfile

   arguments
      root (1,1) string
   end

   try
      proj = matlab.project.rootProject();
      if ~isempty(proj) && startsWith(string(proj.RootFolder), root)
         close(proj)
      end
   catch
      % No Project is open, which is the state the teardown wants.
   end
end
