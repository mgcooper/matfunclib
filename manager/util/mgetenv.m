function value = mgetenv(name)
   %MGETENV Read a path-family variable with the mconfig fallback.
   %
   %  VALUE = MGETENV(NAME) returns getenv(NAME) when it is nonempty.
   %  When it is empty, mgetenv calls mconfig, which recomputes the
   %  path family from $HOME/MATLAB and exports every member, then
   %  returns the recomputed value for NAME.
   %
   % Description
   %
   %  Path builders must never call getenv on a family member directly.
   %  getenv returns '' in a session that did not run mconfig: a session
   %  booted before an environment-variable rename, a -batch run with a
   %  different userpath, or a startup failure. fullfile('', file)
   %  degrades to a bare relative name, and save with a relative name
   %  writes to the current folder. That degradation wrote a registry
   %  snapshot into a repository root at shutdown (matfunclib-47r), so
   %  every family read routes through this fallback.
   %
   %  A nonempty environment value always wins. Test fixtures rely on
   %  that order: they redirect family members to temp folders with
   %  setenv and restore them in teardown.
   %
   %  NAME must be a field mconfig returns; an unknown name errors so a
   %  typo cannot degrade to '' either. No arguments block: startup.m
   %  and finish.m paths must also run under Octave.
   %
   % See also: mconfig getprjdirectorypath gettbdirectorypath

   value = getenv(name);
   if isempty(value)
      % The family was never exported in this session. mconfig is the
      % one definition; calling it also repairs the session for later
      % direct getenv reads.
      cfg = mconfig();
      if ~isfield(cfg, name)
         error('matfunclib:manager:mgetenv:unknownVariable', ...
            '"%s" is not a path-family variable mconfig defines.', name)
      end
      value = cfg.(name);
   end
end
