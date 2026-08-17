function varargout = releasefile()
   %RELEASEFILE Package the toolbox into release/ headless.
   %
   %    releasefile()
   %    mltbxfile = releasefile()
   %
   % Description
   %
   %  Packages the shipped toolbox/ folder into a versioned .mltbx under
   %  release/, entirely headless. The packaging options come from
   %  <namespace>.internal.releaseoptions, which prefers the MATLAB
   %  Project's embedded Package Toolbox task (R2025a) and falls back to
   %  constructing options from the toolbox/ folder, with the version
   %  pinned from version.txt in both cases. After packaging, the
   %  version inside the .mltbx is verified against version.txt, so a
   %  release cannot ship a version that disagrees with the source.
   %
   %  Run `buildtool release` instead to also gate the packaging on the
   %  check and test tasks; that task calls this function.
   %
   % Outputs
   %
   %  MLTBXFILE - Full path of the packaged .mltbx (optional).
   %
   % See also: buildfile, matlab.addons.toolbox.packageToolbox

   % This file sits at the project root, so the root is its own folder.
   root = string(fileparts(mfilename("fullpath")));

   % The shipped namespace provides releaseoptions; put toolbox/ on the
   % path so it resolves without an installed toolbox. shippednamespace
   % is a folder-private helper shared with buildfile.
   addpath(fullfile(root, "toolbox"))
   namespace = shippednamespace(root);
   opts = feval(namespace + ".internal.releaseoptions", root);

   % packageToolbox needs the output folder to exist.
   releasefolder = fullfile(root, "release");
   if ~isfolder(releasefolder)
      mkdir(releasefolder)
   end

   % Package, then verify the packaged version against the pinned one so
   % a stale packaging definition cannot ship the wrong version.
   matlab.addons.toolbox.packageToolbox(opts);
   packagedVersion = string( ...
      matlab.addons.toolbox.toolboxVersion(opts.OutputFile));
   assert(packagedVersion == string(opts.ToolboxVersion), ...
      "Packaged version ""%s"" does not match version.txt ""%s"".", ...
      packagedVersion, opts.ToolboxVersion)

   fprintf(1, "Created toolbox release %s\n", opts.OutputFile);

   % Return the .mltbx path only when asked, so scripted calls do not
   % echo it.
   if nargout
      varargout{1} = string(opts.OutputFile);
   end
end
