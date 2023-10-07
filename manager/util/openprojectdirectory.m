function varargout = openprojectdirectory()
   %OPENPROJECTDIRECTORY Open the project directory in the variable explorer
   %
   % OPENPROJECTDIRECTORY() with no inputs opens the project directory.
   %
   % PROJECTLIST = OPENPROJECTDIRECTORY() also returns the list of projects.
   %
   % See also: lsprojects

   projectlist = readprjdirectory;
   assignin('base', 'projectlist', projectlist);
   varopen projectlist;

   if nargout == 1
      varargout{1} = projectlist;
   end
end
