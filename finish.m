% Don't call 'workoff' because it sets the active project to 'default'.
% Then when matlab is reopened, 'workon' does not open whichever project was
% active when matlab was closed. Instead, use setprojectfiles to update the
% activefiles list.  TODO: add a method to workoff for this purpose.
% Note that if workoff did not set the project to 'default', then if workoff was
% called during an active session and matlab was later closed, setprojectfiles
% would override the activefiles list of the project that was active when
% workoff was called.

% Don't save files if running in terminal
if usejava('desktop')

   % Update the activefiles list
   try
      setprojectfiles(getactiveproject('name'));
   catch e
      if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
         try
            % If the path was removed during the session, add it back.
            addpath(genpath(getenv('MATLABFUNCTIONPATH')), '-end');
            setprojectfiles(getactiveproject('name'));
         catch e
            % If that does not work, throw the error.
            rethrow(e)
         end
      end
   end

   % from projects.m finish:
   % Save the current project and exit the projects() logic
   projects('save', projects('active'));
   projects('close');

   % deactivate active toolboxes
   deactivate('all');
end

% Note: I did this once to confirm it works, but in general I think I need to
% maintain the struct alongside the table not just here
% % write the project directory and toolbox directory to csv for octave
% projectlist = readprjdirectory();
% projectstruct = table2struct(projectlist);
% projectdirectorypath = getprjdirectorypath;
% save(projectdirectorypath, 'projectlist', 'projectstruct')
