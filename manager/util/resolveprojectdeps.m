function resolveprojectdeps(projectname, visiting, owner)
   %RESOLVEPROJECTDEPS Activate a project's declared dependencies.
   %
   %  resolveprojectdeps(projectname) reads PROJECTNAME's mproject.toml
   %  (see readmanifest) and activates every declared dependency that is
   %  not already active: toolbox dependencies through quiet activate calls,
   %  project dependencies through the asproject path-add (never
   %  recursive workon, which would cascade teardowns and hooks). Project
   %  dependencies resolve transitively: each one's own manifest is
   %  resolved with the same visited stack, and a cycle fails fast with
   %  the full chain named.
   %
   %  Every state transition this function causes is recorded in the
   %  depledger under the top-level project, so workoff can reverse
   %  exactly what resolution activated. Dependencies that were already
   %  active are skipped and never recorded, which keeps manual
   %  activations out of teardown's reach.
   %
   %  Unknown dependency names fail fast against the registries before
   %  anything is activated for that entry.
   %
   %  The VISITING and OWNER arguments are internal recursion state; call
   %  the function with one argument.
   %
   % Written in Octave-compatible style (no arguments block); part of the
   % manifest layer, which must run under Octave per the DesignSpec.
   %
   % See also: readmanifest, teardownprojectdeps, depledger, workon

   narginchk(1, 3)
   projectname = char(projectname);
   if nargin < 2
      % Top-level call: on any resolution failure, reverse every state
      % transition this resolution recorded before rethrowing, so a
      % failed workon does not strand half-activated dependencies.
      try
         resolveprojectdeps(projectname, {}, projectname);
      catch resolveErr
         teardownprojectdeps(projectname);
         rethrow(resolveErr)
      end
      return
   end

   % Track this project on the visited stack. The pre-activation check in
   % the project-deps loop consults it, so every real cycle errors there,
   % before the cycle-closing dependency causes any side effect.
   visiting{end+1} = projectname;

   manifest = readmanifest(getprojectfolder(projectname));
   if isempty(manifest.toolboxes) && isempty(manifest.projects)
      return
   end

   % Toolbox dependencies: validate against the registry, skip active
   % ones, activate (without a message) and record the rest.
   toolboxes = readtbdirectory(gettbdirectorypath());
   for k = 1:numel(manifest.toolboxes)
      tbname = manifest.toolboxes{k};
      tbidx = findtbentry(toolboxes, tbname);
      if ~any(tbidx)
         error('matfunclib:resolveprojectdeps:unknownToolbox', ...
            ['Project "%s" declares toolbox dependency "%s", which is ' ...
            'not in the toolbox directory. Register it with addtoolbox ' ...
            'or fix the manifest %s.'], projectname, tbname, manifest.file);
      end
      % requiretoolbox treats a stale registry flag (set, but toolbox
      % absent from the path) as inactive and repairs it; it returns
      % true only when this call caused the activation, which is the
      % transition the ledger records.
      if requiretoolbox(tbname)
         depledger('record', owner, 'toolbox', tbname);
      end
   end

   % Project dependencies: validate against the registry, skip ones whose
   % folder is already on the path, path-add (without a message) and record the
   % rest, then resolve their own manifests transitively.
   projectlist = readprjdirectory();
   for k = 1:numel(manifest.projects)
      depname = manifest.projects{k};
      if ~any(getprjidx(depname, projectlist))
         error('matfunclib:resolveprojectdeps:unknownProject', ...
            ['Project "%s" declares project dependency "%s", which is ' ...
            'not in the project directory. Register it with addproject ' ...
            'or fix the manifest %s.'], projectname, depname, manifest.file);
      end

      % Detect a cycle before activating the dependency, so the error
      % fires without a side effect for the cycle-closing edge.
      if any(strcmpi(visiting, depname))
         chain = strjoin([visiting, {depname}], ' -> ');
         error('matfunclib:resolveprojectdeps:dependencyCycle', ...
            'Dependency cycle detected: %s', chain);
      end

      depfolder = getprojectfolder(depname);
      onpath = any(strcmp(strsplit(path(), pathsep()), depfolder));
      if ~onpath
         activate(depname, 'silent', true, 'asproject', true);
         depledger('record', owner, 'project', depname);
      end

      % Transitive resolution runs even when the dependency was already
      % on the path: its own declared deps may still be missing.
      resolveprojectdeps(depname, visiting, owner);
   end
end
