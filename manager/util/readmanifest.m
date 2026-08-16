function manifest = readmanifest(projectfolder)
   %READMANIFEST Read and validate a project's mproject.toml manifest.
   %
   %  manifest = readmanifest(projectfolder)
   %
   % Returns a struct with fields:
   %   name      - char, the declared project name ('' when undeclared)
   %   projects  - cellstr of project dependency names (registry names)
   %   toolboxes - cellstr of toolbox dependency names (registry names)
   %   file      - char, full path of the manifest ('' when none exists)
   %
   % A missing mproject.toml is not an error: no manifest means no
   % declared dependencies, and the returned lists are empty. A manifest
   % that exists but does not follow the schema fails fast with an
   % identified error. Registry existence of the entries is checked at
   % resolution time (resolveprojectdeps), not here.
   %
   % Schema (see the DesignSpec, settled decision 3):
   %
   %   [project]
   %   name = "myproject"
   %
   %   [dependencies]
   %   projects  = ["exactremap", "activelayer"]
   %   toolboxes = ["b17"]
   %
   % Written in Octave-compatible style (no arguments block); the manifest
   % layer must parse under Octave per the DesignSpec.
   %
   % See also: readtoml, resolveprojectdeps

   narginchk(1, 1)
   projectfolder = char(projectfolder);

   manifest = struct('name', '', 'projects', {{}}, 'toolboxes', {{}}, ...
      'file', '');

   tomlfile = fullfile(projectfolder, 'mproject.toml');
   if exist(tomlfile, 'file') ~= 2
      return
   end
   manifest.file = tomlfile;

   data = readtoml(tomlfile);

   if isfield(data, 'project') && isfield(data.project, 'name')
      manifest.name = char(data.project.name);
   end

   if ~isfield(data, 'dependencies')
      return
   end
   deps = data.dependencies;

   % Reject unknown dependency types so a typo like "toolbox = [...]"
   % fails fast instead of declaring nothing.
   knownfields = {'projects', 'toolboxes'};
   extrafields = setdiff(fieldnames(deps), knownfields);
   if ~isempty(extrafields)
      error('matfunclib:readmanifest:unknownDependencyType', ...
         ['Unknown [dependencies] key "%s" in %s. Supported keys: ' ...
         'projects, toolboxes.'], extrafields{1}, tomlfile);
   end

   manifest.projects = getdeplist(deps, 'projects', tomlfile);
   manifest.toolboxes = getdeplist(deps, 'toolboxes', tomlfile);
end

%% Local functions
function list = getdeplist(deps, fieldname, tomlfile)
   if ~isfield(deps, fieldname)
      list = {};
      return
   end
   list = deps.(fieldname);
   % readtoml returns single-line string arrays as cellstr and a lone
   % string as char; normalize both to a cellstr row.
   if ischar(list)
      list = {list};
   end
   % Cell-of-char check (not iscellstr, whose analyzer message pushes the
   % string class; the manifest layer stays Octave-compatible).
   if ~iscell(list) || ~all(cellfun(@ischar, list))
      error('matfunclib:readmanifest:badDependencyList', ...
         '[dependencies] %s must be an array of strings in %s.', ...
         fieldname, tomlfile);
   end
   list = reshape(list, 1, []);
end
