function report = syncprojectfiles(projectFolder)
   %SYNCPROJECTFILES Import missing required files and refresh dependencies.
   %
   %    report = syncprojectfiles(projectFolder)
   %
   % Description
   %
   %  The maintenance half of Project generation: walks the dependency
   %  requirements of the Project's own code, imports required files that
   %  live under the project root but are not in the Project, and then
   %  refreshes the Project's dependency cache with updateDependencies.
   %
   %  During the walk, every ordinary in-root folder is placed at the
   %  front of the MATLAB path, so a requirement with an in-root copy
   %  resolves to that copy the way it would at run time with the
   %  Project open. This is the deterministic preference for code
   %  inside the project: same-named external copies lose resolution,
   %  and copies whose package, class, or private qualification differs
   %  never match at all.
   %
   %  Files that still resolve OUTSIDE the project root are never
   %  copied or imported: dependency vendoring belongs to
   %  installRequiredFiles and external dependencies belong in
   %  mproject.toml. They are reported instead, so the caller can
   %  declare or vendor them deliberately.
   %
   % Outputs
   %
   %  REPORT - Struct with string-column fields:
   %    added      - in-root required files this call imported;
   %    external   - required files resolving outside the root
   %                 (candidates for the manifest or vendoring).
   %
   % Note: addFile, addPath, and updateDependencies are methods of
   % matlab.project.Project, not path functions, so which -all does
   % not list them. This file writes them with dot notation so they
   % read as methods.
   %
   % See also: createMatlabProject, addprojectrefs, installRequiredFiles

   arguments
      projectFolder (1,1) string {mustBeFolder}
   end

   proj = openProject(projectFolder);
   projectRoot = string(proj.RootFolder);

   % The requirements walk runs on the Project's own MATLAB code, and
   % membership is judged against the Project file set (shared helper
   % with createMatlabProject).
   files = listprojectfiles(proj);
   codefiles = files(endsWith(files, ".m") | endsWith(files, ".mlx"));

   if isempty(codefiles)
      % Nothing to analyze; still refresh the cache so both branches
      % leave the Project synced.
      report = struct("added", strings(0, 1), ...
         "external", strings(0, 1));
      proj.updateDependencies();
      return
   end

   % requiredFilesAndProducts resolves names through the MATLAB path
   % and OMITS what it cannot resolve, so an in-root dependency in a
   % folder that is neither imported nor on the path would never
   % appear as required. Expose every ordinary in-root folder at the
   % front of the path during the walk (genpath already skips
   % +package/@class/private folders), minus version-control and root
   % Project metadata, and restore the path afterward. Front placement
   % is also what makes in-root copies win resolution over same-named
   % external ones.
   candidateFolders = split(string(genpath(projectRoot)), pathsep);
   candidateFolders = candidateFolders(candidateFolders ~= "");
   rootResources = fullfile(projectRoot, "resources");
   candidateFolders = candidateFolders( ...
      candidateFolders ~= rootResources ...
      & ~startsWith(candidateFolders, rootResources + filesep));
   % Version-control folders are matched as complete path segments, so
   % an ordinary folder whose name merely contains ".git" (for example
   % widget.gitlab) stays exposed.
   keep = true(numel(candidateFolders), 1);
   for k = 1:numel(candidateFolders)
      segments = split(erase(candidateFolders(k), ...
         projectRoot + filesep), filesep);
      keep(k) = ~any(ismember(segments, [".git", ".svn"]));
   end
   candidateFolders = candidateFolders(keep);
   savedPath = path();
   restorePath = onCleanup(@() path(savedPath));
   addpath(strjoin(candidateFolders, pathsep))

   required = string(matlab.codetools.requiredFilesAndProducts( ...
      cellstr(codefiles))).';

   % Restore the session path NOW, before any proj.addPath below: the
   % exit-time cleanup would otherwise wipe path entries the Project
   % activates during this call, leaving the returned open Project
   % unable to resolve its own new imports. Clearing the onCleanup
   % runs it once; the object stays armed above for the error paths.
   clear restorePath

   % Membership and containment both use the root path the Project
   % reports, so macOS /var vs /private/var aliases cannot split them.
   inroot = startsWith(required, projectRoot + filesep);

   % In-root requirements missing from the Project import directly; no
   % copy is needed because they already live where they belong.
   toAdd = setdiff(required(inroot), files);
   for k = 1:numel(toAdd)
      proj.addFile(toAdd(k));
   end

   report = struct( ...
      "added", toAdd(:), ...
      "external", required(~inroot));

   % addFile changes membership only; a file imported from a folder
   % with no Project path entry would stay unresolvable after a close
   % and reopen. Register each imported file's path root (its folder,
   % stripped of +package/@class/private qualification through the
   % shared pathrootof) idempotently.
   pathRoots = unique(arrayfun(@(f) pathrootof(string(fileparts(f))), ...
      report.added));

   % MATLAB refuses a Project path entry with a resources segment (the
   % name is reserved for Project metadata), so a file imported from a
   % nested resources folder stays a member without path registration.
   keep = true(numel(pathRoots), 1);
   for k = 1:numel(pathRoots)
      segments = split(erase(pathRoots(k), projectRoot + filesep), ...
         filesep);
      keep(k) = ~any(segments == "resources");
   end
   pathRoots = pathRoots(keep);

   heldPath = listprojectpath(proj);
   for k = 1:numel(pathRoots)
      if ~any(heldPath == pathRoots(k))
         proj.addPath(pathRoots(k));
      end
   end

   % Refresh the dependency cache last, after every import, so the cache
   % reflects the final file set.
   proj.updateDependencies();
end
