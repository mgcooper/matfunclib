function ok = configureproject(projectpath, varargin)
   %CONFIGUREPROJECT Run config, setup, install, and startup scripts in projpath
   %
   %  configureproject(projpath) searches projpath (top level only) for Setup.m,
   %  Install.m, Startup.m, and Config.m files and executes them. Setup.m and
   %  Install.m are synonymous and are assumed to be installation
   %  scripts/functions. Config.m and Startup.m are synonymous and are assumed
   %  to be configuration scripts/functions run each time a project is
   %  activated. To search for a specific installation and/or configuration
   %  file, specify a second argument as a character vector or cell string array
   %  containing the file name.
   %
   %  configureproject(projpath,configscript) searches projpath (top level only)
   %  for a file named configscript and executes it.
   %
   %  ok = configureproject(_) returns true when at least one script or
   %  userhooks/ script ran and every one that ran completed. It returns false
   %  when a script raised an error, or when it found no script. The function
   %  issues a script error as a warning with that error's own identifier and
   %  message. A missing script produces no message, because most projects have
   %  none.
   %
   %  The scripts run with projpath as the current folder, so the script is
   %  always the project's own file, even when another file of the same name is
   %  earlier on the path. The function restores the caller's folder on exit
   %  through withcd. The function refuses a script name that matches one of its
   %  local helpers (matfunclib:configureproject:reservedName). projpath must
   %  name a folder that exists, or withcd raises an error. workon checks the
   %  folder before it changes any state.
   %
   % Example
   %
   %  configureproject(projpath,'Config.m')
   %
   % See also

   % NOTE: for Setup/Install, we don't want to try re-installing stuff if we
   % don't have to, but if there isn't much overhead, we can just let it check
   % if requirements exist

   if nargin == 1
      tryscripts = ...
         {'Config','Setup','Install','Startup','configfile','setupfile'};
   else
      tryscripts = cellstr(varargin{1});
   end
   % A name already in lower case, such as configfile or a caller's 'config',
   % appears twice below. unique keeps one copy, so no script runs twice.
   tryscripts = unique([tryscripts lower(tryscripts)], ...
      'stable'); % removed UPPER for now
   % tryscripts = [tryscripts lower(tryscripts) upper(tryscripts)];

   % Check if a caller-supplied script name matches this file or its local
   % functions, which feval would resolve before the requested name and could
   % run (or recurse) and report success without running the actual script.
   reserved = {mfilename, 'raisedinside', 'runscript', ...
      'reportscripterror', 'entrykind'};
   collision = intersect(tryscripts, reserved);
   if ~isempty(collision)
      error('matfunclib:configureproject:reservedName', ...
         'configureproject: %s is the name of an internal helper', ...
         collision{1});
   end

   % Create an octave compatible function handle to classify errors.
   fs.inoctave = isoctave;
   fs.isundefined = @isundefinedfunction;

   % Every script runs with the project folder current. MATLAB searches the
   % current folder before the path, so a bare name resolves to the file in the
   % project regardless of what else is on path. The bare name also has no
   % path-length limit; feval accepts a full path only up to namelengthmax
   % characters. The resolved folder overwrites the caller's spelling of
   % projectpath, so a relative or ".." path compares equal to the absolute file
   % names in the error stack. withcd restores the caller's folder on exit, and
   % skips the restore when that folder no longer exists (workon cds into the
   % project first, so its restore is a no-op). The loop enters the folder again
   % before each call because a script may cd elsewhere.
   %
   % restorefolder is held for its lifetime, not read. Releasing it early would
   % end the guard, and delete raises on an onCleanup object under Octave, so
   % the analyzer's unused-assignment report is silenced here.
   restorefolder = withcd(projectpath); %#ok<NASGU>
   projectpath = pwd;

   % ok reports success only when a script ran and none failed. A failure
   % persists. A later script that succeeds does not hide an earlier one that
   % raised, because the caller sees one flag for the whole set. The flags live
   % here, and every script executes in a helper's workspace (feval in its own,
   % run in runscript's). A script that assigns a variable named ran or failed
   % therefore cannot alter the result.
   ran = false;
   failed = false;

   for n = 1:numel(tryscripts)

      % Change to the project folder each time in case a script changed the cwd.
      cd(projectpath)
      scriptfile = fullfile(projectpath, [tryscripts{n} '.m']);

      % Use dir rather than isfile to determine file existence - a file system
      % that folds case reports 'setup.m' present when 'Setup.m' exists. MATLAB
      % resolves names case-sensitively, so the bare call 'setup' would reach a
      % same-named file elsewhere on the path or fail. List the folder each
      % iteration because an earlier script may create or remove one. The
      % listing uses a relative pattern, because dir reads '*' or '?' in the
      % project path itself as wildcards and would list a sibling folder.
      listing = dir('*.m');
      present = {listing(~[listing.isdir]).name};
      if any(strcmp(present, [tryscripts{n} '.m']))
         try
            % this should work if the script is a function that accepts at
            % least one argument (most likely it will be varargin)
            feval(tryscripts{n},[]);
         catch ME

            % this is a case-insensitive match e.g. 'Config.m' exists and this
            % try is 'config.m' (note: if feval doesn't care about case, then we
            % don't need to loop over both cases). Only an undefined script
            % itself is the skip. An undefined name raised from inside the
            % script is the script's own error, reported below. The script's
            % frame in the error's stack tells the two apart, and entrykind
            % names the MATLAB and Octave forms of each error.
            kind = entrykind(ME, tryscripts{n}, scriptfile, fs);
            if strcmp(kind, 'undefined')
               continue
            end

            % this occurs when the setup function accepts no inputs. The retry's
            % failure is the script's own error, so reportscripterror reports it
            % (matfunclib-juq.38). The same identifier raised from inside the
            % script (a helper called with too many inputs) is the script's
            % error, not a signature mismatch, so the loop reports it and does
            % not retry.
            if strcmp(kind, 'toomany')
               try
                  cd(projectpath)
                  feval(tryscripts{n});
               catch ME
                  failed = reportscripterror(ME, tryscripts{n}, projectpath);
               end

               % if feval fails, try run (the case where the setup file is a
               % script). run gets the full path so it executes the file the
               % listing found.
            elseif strcmp(kind, 'script')
               try
                  cd(projectpath)
                  runscript(scriptfile);
               catch ME
                  % A failing run gets a warning.
                  failed = reportscripterror(ME, tryscripts{n}, projectpath);
               end

            else
               % Any other error is the script's own error. reportscripterror
               % warns with its own identifier and message, and the activation
               % reports the failure.
               failed = reportscripterror(ME, tryscripts{n}, projectpath);
            end
         end
         ran = true;
      end
   end

   % Run user hooks (e.g., config.m, read .env, etc). The dot folder removal
   % should not ever be necessary, but it doesn't hurt to check. A failing hook
   % is part of the project's configuration, so the loop reports and counts it
   % like a top-level script (audit MEDIUM #24). The loop drops a folder named
   % like a script, as in the top-level listing. The loop lists the folder again
   % after every hook, because a hook may create or remove another: a created
   % hook runs, and a removed one gets no report. Hooks run in name order, each
   % once. The bookkeeping stays in cell arrays because Octave has no string
   % arrays, and the listing is relative to the project folder for the wildcard
   % reason above.
   ranhooks = {};
   while true
      cd(projectpath)
      hookslist = dir(fullfile('userhooks', '*.m'));
      hookslist = hookslist(~[hookslist.isdir]);
      userhooks = fullfile({hookslist.folder}.', {hookslist.name}.');
      userhooks = userhooks(cellfun(@(p) ~endsWith(p, '.'), userhooks));
      pending = setdiff(userhooks, ranhooks, 'stable');
      if isempty(pending)
         break
      end
      hook = pending{1};
      try
         runscript(hook);
      catch ME
         failed = reportscripterror(ME, hook, projectpath);
      end
      ran = true;
      ranhooks = union(ranhooks, {hook});
   end

   % A project with no script is normal (most projects have none), so the
   % function prints nothing here. The ok output is returned to the caller.
   ok = ran && ~failed;
end

function kind = entrykind(ME, name, scriptfile, fs)
   %ENTRYKIND Classify an error from calling NAME: how it failed to enter.
   %
   % Returns 'undefined' (the script could not be resolved: the skip), 'toomany'
   % (a function that takes no input was given one: retry with none), 'script'
   % (a script was called as a function: retry with run), or '' (the script's
   % own internal error, reported). MATLAB carries each case in an identifier.
   % Octave carries two of them only in the message, with an empty identifier.
   % Octave also raises its too-many-inputs error from the callee's own frame,
   % so the frame test applies to MATLAB only. FS holds the helpers resolved
   % before the loop entered the project folder.
   id = ME.identifier;
   msg = ME.message;
   kind = '';
   if fs.inoctave
      if isempty(id) && contains(msg, ['function ''' name ''' not found'])
         kind = 'undefined';
      elseif strcmp(id, 'Octave:invalid-fun-call') && ...
            startsWith(msg, [name ': function called with too many inputs'])
         kind = 'toomany';
      elseif isempty(id) && startsWith(msg, 'invalid call to script')
         kind = 'script';
      end
      return
   end
   if raisedinside(ME, scriptfile)
      return
   end
   if fs.isundefined(ME)
      kind = 'undefined';
   elseif strcmp(id, 'MATLAB:TooManyInputs')
      kind = 'toomany';
   elseif any(strcmp(id, {'MATLAB:feval:invalidFunctionName', ...
         'MATLAB:scriptNotAFunction'}))
      % feval of a bare script name raises scriptNotAFunction.
      % invalidFunctionName covers a name feval cannot parse.
      kind = 'script';
   end
end

function tf = raisedinside(ME, scriptfile)
   %RAISEDINSIDE True when ME was raised from a frame of SCRIPTFILE.
   %
   % MATLAB raises MATLAB:UndefinedFunction, MATLAB:TooManyInputs and
   % MATLAB:feval:invalidFunctionName in two cases. One is when it cannot enter
   % the script itself (the skip and the retries). The other is when a call
   % inside the script fails the same way (the script's own error). An error
   % that never entered the script has no frame from its file. The comparison
   % ignores case because the loop tries both spellings of the name.
   tf = any(strcmpi({ME.stack.file}, scriptfile));
end

function runscript(scriptname)
   %RUNSCRIPT Execute a script in this helper's own workspace.
   %
   % run executes the script in the caller's workspace. This wrapper keeps the
   % script's variables out of configureproject, where they could overwrite the
   % ran and failed flags.
   run(scriptname)
end

function failed = reportscripterror(ME, scriptname, projectpath)
   %REPORTSCRIPTERROR Warn with the script's own error and flag the failure.
   %
   % The warning carries the caught error's identifier so a caller or a test can
   % match it. Its message names the script and the project so the user knows
   % which configuration broke. An error without an identifier gets a generic
   % one, because warning needs a valid identifier.
   id = ME.identifier;
   if isempty(id)
      id = 'matfunclib:configureproject:scriptFailed';
   end
   warning(id, 'configureproject: %s in %s failed: %s', ...
      scriptname, projectpath, ME.message);
   failed = true;
end
