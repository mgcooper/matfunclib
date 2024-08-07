function setup()
   % SETUP set paths etc.
   %
   % See also: config configureproject

   % Store the initial warning state.
   initialWarningState = warning;

   % Create onCleanup object to restore warning state when function terminates.
   cleanupObj = onCleanup(@() warning(initialWarningState));

   % Turn off warnings about paths not already being on the path.
   warning('off', 'MATLAB:rmpath:DirNotFound')

   % Get the path to this file.
   thispath = fileparts(mfilename('fullpath'));

   % This is true if running in desktop. Use it to suppress interactions with
   % editor such as opening or closing project files.
   if usejava('desktop')

   end

   % Safely add all paths.
   pathadd(thispath)

   % Resolve dependencies

   % Set preferences
   % setpref('mytoolbox', 'version', toolboxversion)
   % addpref('mytoolbox', 'toolboxdir', thispath);

   % run config, startup, read .env, etc
   try
      run(fullfile(thispath, 'config'));
   catch
   end
end

% Notes
% - toolboxdir returns the full path to mathworks toolboxes, needed for compiler
% - tbxprefix returns the root folder for mathworks toolboxes (its a builtin func)
% - tempname, tempdir create temp folders and temp files
% - use dbstack to get the file that called a function. For Config, might add a
% check that workon called it (or configurepackage) or it was called directly
% which might require checking mfilename('fullpath') so as to rule out other
% Config files. If called from the command window or terminal I'm not sure.

function pathadd(pathstring)

   % Generate a list of sub-folders. genpath ignores folders named private, folders
   % that begin with the @ character (class folders), folders that begin with the +
   % character (package folders), folders named resources, or subfolders within any
   % of these.
   subpaths = strsplit(genpath(pathstring), pathsep);

   % Specify additional ignore folders.
   ignorepaths = {'.git', '.svn', 'CVS', '.', '..'};

   % Remove ignored folders.
   keep = @(folders, ignore) cellfun('isempty', (strfind(folders, ignore)));
   for n = 1:numel(ignorepaths)
      subpaths = subpaths(keep(subpaths, ignorepaths(n)));
   end

   % Rebuild the path string
   pathstring = strcat(subpaths, pathsep);
   pathstring = horzcat(pathstring{:});

   % Add the paths to the end of the path
   addpath(pathstring, '-end');

   % Save the path (not enabled, generally do not want this)
   % savepath(fullfile(thispath,'pathdef.m'));
end
