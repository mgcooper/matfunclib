function varargout = requiretoolbox(tbname)
   %REQUIRETOOLBOX Ensure a registered toolbox is active.
   %
   %  requiretoolbox(tbname) activates toolbox TBNAME (without printing a
   %  message) when it is not already active, and does nothing when it is.
   %
   %  activated = requiretoolbox(tbname) returns true when this call
   %  activated the toolbox and false when it was already active.
   %
   %  "Already active" means the registry flag is set AND the toolbox
   %  source folder is on the MATLAB path. The persisted flag alone is
   %  not trusted: it survives sessions (headless exits and crashes skip
   %  the finish.m cleanup) while the path resets, so a stale flag with
   %  the toolbox absent from the path gets repaired by activating.
   %
   % This is the lazy, call-site form of a toolbox dependency: library
   % functions that need a toolbox at run time call this so they keep
   % working for users on the ambient path who never ran workon. The
   % declarative form is an mproject.toml [dependencies] toolboxes entry,
   % which workon resolves up front (matfunclib's own manifest declares
   % the toolboxes its library functions require). Activation here counts
   % as a direct user action: it is not recorded in the depledger, so
   % workoff never reverses it.
   %
   % Written in Octave-compatible style (no arguments block); part of the
   % manifest layer, which must run under Octave per the DesignSpec.
   %
   % See also: activate, resolveprojectdeps, readmanifest

   narginchk(1, 1)
   tbname = char(tbname);

   toolboxes = readtbdirectory(gettbdirectorypath());
   tbidx = findtbentry(toolboxes, tbname);
   if ~any(tbidx)
      error('matfunclib:requiretoolbox:unknownToolbox', ...
         ['Toolbox "%s" is not in the toolbox directory. Register it ' ...
         'with addtoolbox.'], tbname);
   end

   tbpath = toolboxes.source{tbidx};
   onpath = any(strcmp(strsplit(path(), pathsep()), tbpath));
   activated = false;
   if ~(logical(toolboxes.active(tbidx)) && onpath)
      activate(tbname, 'silent', true);
      activated = true;
   end
   if nargout > 0
      varargout{1} = activated;
   end
end
