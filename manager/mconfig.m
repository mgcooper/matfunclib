function cfg = mconfig()
   %MCONFIG Configure the MATLAB path-family environment variables.
   %
   %  CFG = MCONFIG() sets the path-family environment variables from the
   %  $HOME/MATLAB root and returns them as fields of the struct CFG.
   %
   % Description
   %
   %  mconfig is the one place that sets the path family (matfunclib-juq.7).
   %  startup.m calls it at boot; consumers read the variables with
   %  mgetenv, which falls back to this function when a variable is
   %  unset (matfunclib-47r).
   %  Do not setenv these names elsewhere. Test fixtures are the exception:
   %  they save the caller's values, redirect family members (for example
   %  MATLAB_DIRECTORY_PATH, MATLAB_PROJECT_PATH, MATLAB_TOOLBOX_PATH) to
   %  temp folders, and restore them in teardown.
   %
   %  Variables set, one per CFG field:
   %
   %     MATLAB_HOME_PATH              $HOME/MATLAB
   %     MATLAB_PROJECT_PATH           $HOME/MATLAB/projects
   %     MATLAB_TOOLBOX_PATH           $HOME/MATLAB/toolboxes
   %     MATLAB_DIRECTORY_PATH         $HOME/MATLAB/directory
   %     MATLAB_FUNCTION_PATH          $HOME/MATLAB/projects/matfunclib
   %     MATLAB_TEMPLATE_PATH          $HOME/MATLAB/projects/matfunclib/templates
   %     MATLAB_TOOLBOX_TEMPLATE_PATH  $HOME/MATLAB/projects/matfunclib/toolbox
   %     MATLAB_FEX_PATH               $HOME/MATLAB/projects/fexlib
   %
   %  MATLAB_DIRECTORY_PATH holds both manager registries: the toolbox
   %  registry (toolboxdirectory.csv) and the project registry
   %  (projectdirectory.mat). MATLAB_FEX_PATH holds the file-exchange
   %  function library (fexlib).
   %
   %  Note: no arguments block and no string types. Octave runs startup.m and
   %  cannot parse arguments blocks, and startup.m calls this function before
   %  the rest of matfunclib is on the path, so it must stand alone.
   %
   % Outputs
   %
   %  CFG - A struct with one field per variable above, holding the value set.
   %
   % See also: startup getenvall

   % Derive the family from the one root: $HOME/MATLAB. Refuse an empty
   % HOME: it would make every family value a relative 'MATLAB/...'
   % prefix, which passes isempty guards yet resolves against cwd
   % (matfunclib-47r).
   if isempty(getenv('HOME'))
      error('matfunclib:manager:mconfig:emptyHome', ...
         'HOME is unset or empty; the path family cannot be derived.')
   end
   homepath = fullfile(getenv('HOME'), 'MATLAB');

   cfg.MATLAB_HOME_PATH = homepath;
   cfg.MATLAB_PROJECT_PATH = fullfile(homepath, 'projects');
   cfg.MATLAB_TOOLBOX_PATH = fullfile(homepath, 'toolboxes');
   cfg.MATLAB_DIRECTORY_PATH = fullfile(homepath, 'directory');
   cfg.MATLAB_FUNCTION_PATH = fullfile(homepath, 'projects', 'matfunclib');
   cfg.MATLAB_TEMPLATE_PATH = fullfile( ...
      cfg.MATLAB_FUNCTION_PATH, 'templates');
   cfg.MATLAB_TOOLBOX_TEMPLATE_PATH = fullfile( ...
      cfg.MATLAB_FUNCTION_PATH, 'toolbox');
   cfg.MATLAB_FEX_PATH = fullfile(homepath, 'projects', 'fexlib');

   % Export every field, so the struct and the environment always agree.
   names = fieldnames(cfg);
   for n = 1:numel(names)
      setenv(names{n}, cfg.(names{n}));
   end
end
