function releasefile(toolboxName)
   %RELEASEFILE build, test and package a MATLAB toolbox
   %
   % releasefile(toolboxname) creates ToolboxName-vX.X.X.mtlbx in release/.
   %
   % NOTE: The current version of the toolbox is assumed to be installed, and
   % the release version is assumed to be up to date in the 'Contents.m' file.
   % This is not intended to create an initial release or install a current
   % version. Instead, use projectfile to setup the project and create an
   % initial release. This function appends the version number to the
   % toolboxname when constructing the .mltbx file, thus it is recommended to do
   % the same with the initial .mltbx file.
   %
   % This function is a replacement for buildfile for matlab versions that do
   % not support buildplan. It also does not rely on the r2023a function
   % matlab.addons.toolbox.ToolboxOptions.
   %
   % Note that this function does require R2019a or higher to use the
   % matlab.addons.toolbox.packageToolbox function.
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % Based on 'release' function, Copyright 2016-2020 The MathWorks, Inc.
   %
   % See also: buildfile buildplan

   % NOTE: This is not functional in general, but may work if there is a .prj
   % file in the current directory which matches <toolboxname>.prj and a release
   % file in the release/ directory which matches <

   %% Assert requirements
   narginchk(1, 1)
   assert(~verLessThan( 'MATLAB', '9.6'), ...
      'MATLAB R2019a or higher is required to use releasefile.')

   %% Parse inputs

   % Get toolbox name and project paths (release/, test/, toolbox/)
   toolboxName = convertStringsToChars(toolboxName);

   % Parse the toolbox/ (or <toolboxname>/) directory path
   projectPath = fileparts(mfilename('fullpath'));
   toolboxPath = fullfile(projectPath, toolboxName);

   if ~isfolder(toolboxPath) && isfolder(fullfile(projectPath, 'toolbox'))
      toolboxPath = fullfile(projectPath, 'toolbox');
   else
      assert(isfolder(toolboxPath), 'toolbox path not found')
   end

   % Parse the release/ directory path
   releasepath = parsesubpath(projectPath, {'release', 'releases'}, ...
      'release', true);

   % Parse the test/ directory path
   [testspath, found_tests] = parsesubpath(projectPath, {'test', 'tests'}, ...
      'test', false);

   %% Check installation
   fprintf(1, 'Checking installation...');
   v = ver(toolboxName);
   switch numel(v)
      case 0
         fprintf(1, ' failed.\n');

         % I think this error prevents later errors e.g. no .prj file found, but
         % it also requires the toolbox be installed which it seems this
         % function should do if it is not installed. UPDATE: That may be a
         % better task for projectfile. But I kept this commented out so in
         % dry-running this function it does not fail here. Uncomment this and
         % add a descriptive message.
         %
         % error('%s not found. Try installing it first with projectfile.m.', ...
         %    toolboxname);
      case 1
         % OK so far
         fprintf(1, ' Done.\n');
      otherwise
         fprintf(1, ' failed.\n');
         error('There are multiple copies of ''%s'' on the MATLAB path.', ...
            toolboxName);
   end

   %% Build documentation & examples
   fprintf(1, 'Generating documentation & examples...');
   try
      % Do something;
      fprintf(1, ' Done.\n');
   catch e
      fprintf(1, ' failed.\n');
      e.rethrow()
   end

   %Build doc search database
   try
      builddocsearchdb(fullfile(toolboxPath, 'doc'));
   catch me
      warning(me.message)
   end

   %% Run tests
   fprintf(1, 'Running tests...');
   if found_tests
      [log, results] = evalc(sprintf('runtests(''%s'')', testspath));

      if ~any([results.Failed])
         fprintf(1, ' Done.\n');
      else
         fprintf(1, ' failed.\n');
         error('%s', log)
      end
   else
      fprintf(1, ' No tests found.\n');
   end

   %% Package and rename.
   fprintf(1, 'Packaging...');
   try
      % Update the .prj file. packageToolbox will create <toolboxName>.mltbx.
      prjfile = fullfile(projectPath, [toolboxName, '.prj']);
      matlab.addons.toolbox.packageToolbox(prjfile);

      % Create a versioned filename by appending the version number.
      mltbx_file = fullfile(projectPath, [toolboxName '.mltbx']);
      mltbx_file_versioned_release = fullfile(releasepath, ...
         [toolboxName ' v' v.Version '.mltbx']);

      % This was how mltbx_file was constructed originally. I don't see why this
      % should be used instead of the fullfile method with projectPath, which I
      % don't think depends on where this function is called from. Kept for
      % reference.
      % mltbx_file = which([toolboxName '.mltbx']);

      % Move the <toolboxName>.mltbx file to a versioned release.
      movefile(mltbx_file, mltbx_file_versioned_release)
      fprintf(1, ' Done.\n');
   catch e
      fprintf(1, ' failed.\n');
      fprintf(1, 'No .prj file found. Try running projectfile to create a project.\n');
      e.rethrow()
   end

   %% Check toolbox
   fprintf(1, 'Checking toolbox...');
   tver = matlab.addons.toolbox.toolboxVersion(mltbx_file_versioned_release);

   if strcmp(tver, v.Version)
      fprintf(1, ' Done.\n');
   else
      fprintf(1, ' failed.\n');
      error('Toolbox version ''%s'' does not match code version ''%s''.', ...
         tver, v.Version)
   end

   %% Show message
   fprintf(1, 'Created versioned toolbox release file ''%s''.\n', ...
      mltbx_file_versioned_release);
end
