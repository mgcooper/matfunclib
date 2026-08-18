function [refs, removed] = addprojectrefs(projectFolder, opts)
   %ADDPROJECTREFS Reconcile Referenced Projects with mproject.toml.
   %
   %    refs = addprojectrefs(projectFolder)
   %    [refs, removed] = addprojectrefs(projectFolder, subprojects=folders)
   %
   % Description
   %
   %  Makes the Project's reference set match what is declared, in both
   %  directions: missing references are added and undeclared ones are
   %  removed, so the .prj graph stays derived from the declarations
   %  rather than accumulating stale edges. Two reference kinds:
   %
   %  - External references: each name in the mproject.toml projects
   %    list resolves to a folder through the project directory
   %    (readprjdirectory + getprojectfolder), the same lookup
   %    resolveprojectdeps uses. The manifest's presence is the opt-in:
   %    when mproject.toml exists, held external references that the
   %    manifest does not declare are removed (an empty projects list
   %    removes them all); when no manifest exists, nothing is added or
   %    removed.
   %
   %  - Internal references: the "subprojects" option lists subfolders
   %    of PROJECTFOLDER (given relative to it) that are Projects in
   %    their own right, the matfunclib hub layout. They are not
   %    manifest entries because the manifest declares external
   %    dependencies only. Held internal references are reconciled only
   %    when the option is passed; a call without it leaves them
   %    untouched, so a manifest-only pass cannot strip a hub's
   %    sub-library references, and an explicit empty list
   %    (subprojects=strings(0,1)) removes them all.
   %
   %  Every reference target must already be an openable MATLAB
   %  Project: addReference requires it, which forces leaves-first
   %  generation over the dependency graph. A target that is not fails
   %  fast with an identified error before any mutation.
   %
   %  Dependency cycles across the transitive manifests fail fast with
   %  the full chain named, before any side effect, matching
   %  resolveprojectdeps.
   %
   %  A re-run with unchanged declarations adds and removes nothing
   %  (idempotent).
   %
   % Outputs
   %
   %  REFS - String column of the reference target folders this call
   %  added (empty when everything declared was already referenced).
   %
   %  REMOVED - String column of the reference target folders this call
   %  removed because the declarations do not cover them.
   %
   % Note: addReference and removeReference are methods of
   % matlab.project.Project, not path functions, so which -all does
   % not list them. This file writes them with dot notation so they
   % read as methods.
   %
   % See also: createMatlabProject, readmanifest, resolveprojectdeps

   arguments
      projectFolder (1,1) string {mustBeFolder}
      % The missing default separates "option omitted" (internal
      % references untouched) from an explicit empty list, which
      % reconciles the internal references down to none.
      opts.subprojects (:,1) string = string(NaN)
   end

   % Resolve every declared target and fail fast on cycles and
   % non-Project targets BEFORE opening or mutating anything, so an
   % error leaves the reference set as it was. The target count is
   % known up front, so the list is preallocated and filled by index.
   manifest = readmanifest(char(projectFolder));
   hasManifest = ~isempty(manifest.file);
   subsPassed = ~(isscalar(opts.subprojects) ...
      && ismissing(opts.subprojects));
   if ~subsPassed
      opts.subprojects = string.empty(0, 1);
   end
   ndeps = numel(manifest.projects);
   nsubs = numel(opts.subprojects);
   targets = strings(ndeps + nsubs, 1);

   % Nothing declares anything: no manifest to reconcile against and no
   % internal request, so return without opening the Project or reading
   % the project directory.
   if ~hasManifest && ~subsPassed
      refs = strings(0, 1);
      removed = strings(0, 1);
      return
   end

   % External targets from the manifest, resolved through the project
   % directory. The directory is read only when the manifest declares
   % project dependencies.
   projectlist = table();
   if ndeps > 0
      projectlist = readprjdirectory();
   end
   for k = 1:ndeps
      depname = manifest.projects{k};
      if ~any(getprjidx(depname, projectlist))
         error("matfunclib:addprojectrefs:unknownProject", ...
            "Project ""%s"" declares project dependency ""%s"", which " + ...
            "is not in the project directory. Register it with " + ...
            "addproject or fix the manifest %s.", ...
            projectFolder, depname, manifest.file)
      end
      targets(k) = string(getprojectfolder(depname));
   end

   % Cycle check over the transitive manifest graph. The walk reads
   % manifests only (no activation, no Project mutation), so a cycle
   % error here has zero side effects. The walk starts from the root
   % manifest already in hand and seeds the visited stack with the
   % manifest's own declared name, the identity a dependency's manifest
   % would name to close a cycle. Seeding from the folder basename would
   % miss cycles whenever the folder name and the declared name differ.
   % With no declared project deps there is no edge to start a cycle.
   for k = 1:ndeps
      checkManifestCycles(manifest.projects{k}, {char(manifest.name)}, ...
         projectlist);
   end

   % Internal targets: subfolders of the project that are Projects
   % themselves (the hub layout).
   for k = 1:nsubs
      targets(ndeps + k) = fullfile(projectFolder, opts.subprojects(k));
   end

   % Canonicalize and deduplicate before any comparison: a relative
   % projectFolder or an aliased directory path would otherwise never
   % match the absolute RootFolder values held references report, so
   % reconciliation could remove a declared edge or add one twice, and
   % a dependency declared twice would double-add. The kind split
   % survives via the counts, so removal scoping stays per kind.
   externalTargets = unique(canonicalfolder(targets(1:ndeps)), "stable");
   internalTargets = unique(canonicalfolder(targets(ndeps + 1:end)), ...
      "stable");
   targets = [externalTargets; internalTargets];
   ndeps = numel(externalTargets);

   % Every target must already be an openable Project or addReference
   % fails inside the API with a less useful message. projectstate is
   % the same classification createMatlabProject applies, so an
   % orphaned target (partial Project state) is reported here, before
   % any reference lands, instead of passing a marker check and failing
   % after mutations. This is the leaves-first precondition, surfaced
   % with the target named.
   for k = 1:numel(targets)
      if projectstate(targets(k)) ~= "project"
         error("matfunclib:addprojectrefs:targetNotAProject", ...
            "Reference target ""%s"" is not an openable MATLAB " + ...
            "Project (state: %s). Generate its Project first " + ...
            "(leaves-first over the dependency graph).", ...
            targets(k), projectstate(targets(k)))
      end
   end

   % Open the Project and reconcile: add declared references it lacks,
   % remove held ones the declarations do not cover. Additions and
   % removals both compare canonical paths against the held set, which
   % is what makes an unchanged re-run a no-op.
   proj = openProject(projectFolder);
   projectRoot = string(proj.RootFolder);
   held = heldReferenceFolders(proj);

   refs = targets(~ismember(targets, held));
   for k = 1:numel(refs)
      proj.addReference(refs(k), "relative");
   end

   % Removal scope per reference kind: external held references (target
   % outside the project root) reconcile against the manifest whenever
   % one exists; internal held references (target under the root)
   % reconcile whenever this call passed the subprojects option, so an
   % explicit empty list removes them all and an omitted option leaves
   % them alone.
   heldInternal = startsWith(held, projectRoot + filesep);
   externalDeclared = targets(1:ndeps);
   internalDeclared = targets(ndeps + 1:end);
   drop = false(numel(held), 1);
   for k = 1:numel(held)
      if heldInternal(k)
         drop(k) = subsPassed && ~ismember(held(k), internalDeclared);
      else
         drop(k) = hasManifest && ~ismember(held(k), externalDeclared);
      end
   end
   removed = held(drop);
   for k = 1:numel(removed)
      proj.removeReference(removed(k));
   end
end

%% local functions

function checkManifestCycles(projectname, visiting, projectlist)
   %CHECKMANIFESTCYCLES Walk transitive manifests and error on a cycle.

   arguments
      projectname (1,:) char
      visiting (1,:) cell
      projectlist table
   end

   if any(strcmpi(visiting, projectname))
      chain = strjoin([visiting, {projectname}], " -> ");
      error("matfunclib:addprojectrefs:dependencyCycle", ...
         "Dependency cycle detected: %s", chain)
   end
   visiting{end + 1} = projectname;

   % Transitive names that are not in the project directory cannot have
   % their manifests read, so they end the walk; the caller's
   % validation loop is what reports undeclarable DIRECT dependencies.
   if ~any(getprjidx(projectname, projectlist))
      return
   end

   manifest = readmanifest(getprojectfolder(projectname));
   for k = 1:numel(manifest.projects)
      checkManifestCycles(manifest.projects{k}, visiting, projectlist);
   end
end

function folders = canonicalfolder(folders)
   %CANONICALFOLDER Resolve folders to absolute canonical paths.
   %
   % dir() reports each entry's parent through the filesystem's
   % resolved path, so listing the folder's dot entry converts a
   % relative or aliased path (macOS /var vs /private/var) into the
   % same absolute form proj.RootFolder reports.

   arguments
      folders (:,1) string
   end

   for k = 1:numel(folders)
      listing = dir(fullfile(folders(k), "."));
      if ~isempty(listing)
         folders(k) = string(listing(1).folder);
      end
   end
end

function held = heldReferenceFolders(proj)
   %HELDREFERENCEFOLDERS Root folders of the Project's current references.

   arguments
      proj (1,1) matlab.project.Project
   end

   nrefs = numel(proj.ProjectReferences);
   held = strings(nrefs, 1);
   for k = 1:nrefs
      % A broken reference has no loadable Project; fall back to the
      % stored File value, which is itself the resolved target folder
      % (the same folder addReference was given), so broken targets
      % still count as held and can be removed by that folder.
      try
         held(k) = string(proj.ProjectReferences(k).Project.RootFolder);
      catch
         held(k) = string(proj.ProjectReferences(k).File);
      end
   end
end
