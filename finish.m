% Don't call 'workoff' because it sets the active project to 'default'.
% Then when matlab is reopened, 'workon' does not open whichever project was
% active when matlab was closed. Instead, use setprojectfiles to update the
% activefiles list.  TODO: add a method to workoff for this purpose.
% Note that if workoff did not set the project to 'default', then if workoff was
% called during an active session and matlab was later closed, setprojectfiles
% would override the activefiles list of the project that was active when
% workoff was called.

% Only save files if running in Matlab Editor (not terminal or octave gui)
if usejava('desktop')

   % Update the activefiles list
   try
      setprojectfiles(getactiveproject('name'));
   catch e
      if strcmp(e.identifier, 'MATLAB:UndefinedFunction')
         try
            % If the path was removed during the session, add it back.
            % Derive the root from $HOME when the variable is unset:
            % manager may be off the path here, so mgetenv and mconfig
            % are unreachable, and genpath('') would make the addpath a
            % no-op (matfunclib-47r).
            funcpath = getenv('MATLAB_FUNCTION_PATH');
            if isempty(funcpath)
               funcpath = fullfile( ...
                  getenv('HOME'), 'MATLAB', 'projects', 'matfunclib');
            end
            addpath(genpath(funcpath), '-end');
            setprojectfiles(getactiveproject('name'));
         catch e
            % If that does not work, throw the error.
            rethrow(e)
         end
      else
         % A save failure must be visible. A swallowed error here let a
         % registry snapshot land in cwd with nothing reported
         % (matfunclib-47r). Warn instead of rethrow so an error cannot
         % cancel the quit.
         warning('finish:setprojectfiles', ...
            'setprojectfiles failed at shutdown: %s', e.message)
      end
   end

   % from projects.m finish:
   % Save the current project and exit the projects() logic
   try
      % projects('save', projects('active'));
      % projects('close');
   catch
   end

   % deactivate active toolboxes. An error in finish.m can cancel the
   % quit, so keep the registry write from blocking shutdown; warn so
   % the failure stays visible (matfunclib-47r).
   try
      deactivate('all');
   catch e
      warning('finish:deactivate', ...
         'deactivate failed at shutdown: %s', e.message)
   end
end

% Note: I did this once to confirm it works, but in general I think I need to
% maintain the struct alongside the table not just here
% % write the project directory and toolbox directory to csv for octave
% projectlist = readprjdirectory();
% projectstruct = table2struct(projectlist);
% projectdirectorypath = getprjdirectorypath;
% save(projectdirectorypath, 'projectlist', 'projectstruct')
