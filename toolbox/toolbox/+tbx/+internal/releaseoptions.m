function opts = releaseoptions(root)
   %RELEASEOPTIONS Build the packaging options a release uses.
   %
   %    opts = tbx.internal.releaseoptions(root)
   %
   % Description
   %
   %  Returns the matlab.addons.toolbox.ToolboxOptions that releasefile
   %  and the buildfile release task package. ROOT is the project root,
   %  the folder holding buildfile.m.
   %
   %  Two sources, in preference order:
   %
   %  1. The MATLAB Project's embedded Package Toolbox task (R2025a),
   %     read through ToolboxOptions(prjfile). The task carries the
   %     identifier, author fields, file list, and exclusions, so the
   %     release has one definition instead of a second packaging prj.
   %  2. When no root .prj carries a packaging task, options are
   %     constructed from the shipped toolbox/ folder with the
   %     deterministic identifier "<encoded>-toolbox", where the
   %     project name is encoded injectively into the characters
   %     ToolboxOptions allows ([A-Za-z0-9-]): letters and digits pass
   %     through, "-" becomes "--", and any other character becomes
   %     "-" followed by its two-lowercase-hex code ("_" -> "-5f").
   %     The encoding is reversible, so two distinct project names can
   %     never share the identifier installs upgrade by, and it must
   %     stay stable across releases or an install adds a second copy
   %     instead of upgrading in place, which is why it derives from
   %     the project name and not from a random id minted per call.
   %
   %  In both cases the version is overridden from version.txt (read
   %  through <namespace>.internal.version), so a release cannot ship a
   %  version that disagrees with the source, and the output lands in
   %  release/ under a versioned filename.
   %
   %  This function reads state and returns options; it never packages.
   %  That split lets the manifest test in test/ verify what a release
   %  would ship without building one.
   %
   % See also: releasefile, buildfile, matlab.addons.toolbox.packageToolbox

   arguments
      root (1,1) string {mustBeFolder}
   end

   % fileparts treats a dot in a folder name as an extension separator,
   % so rejoin the parts to keep dotted project names ("my.project")
   % whole.
   [~, projectbase, projectext] = fileparts(root);
   projectname = string(projectbase) + string(projectext);

   % Source 1: a root .prj whose Project embeds the Package Toolbox
   % task. Two identifiers mean "no packaging task here" and select the
   % fallback: NotValidToolboxPRJ (a .prj that is not a Project
   % packaging file) and NO_TOOLBOX_TASK (a real Project whose .prj
   % carries no embedded task, the state projectfile() creates). Any
   % other error (a malformed task, a permission failure) rethrows,
   % because falling back would package different files or metadata
   % than the task defines.
   noTaskIds = [ ...
      "MATLAB:toolbox_packaging:packaging:NotValidToolboxPRJ", ...
      "deployment:exception:NO_TOOLBOX_TASK"];
   opts = matlab.addons.toolbox.ToolboxOptions.empty;
   prjfiles = dir(fullfile(root, "*.prj"));
   for k = 1:numel(prjfiles)
      try
         opts = matlab.addons.toolbox.ToolboxOptions( ...
            fullfile(root, prjfiles(k).name));
         break
      catch readErr
         if ~any(readErr.identifier == noTaskIds)
            rethrow(readErr)
         end
         % No packaging task in this prj; try the next candidate or
         % fall back to folder construction below.
      end
   end

   % Source 2: construct from the shipped folder with the deterministic
   % identifier. The injective encoding means no pair of distinct names
   % can share the identifier installs upgrade by.
   if isempty(opts)
      identifier = encodeidentifier(projectname) + "-toolbox";
      opts = matlab.addons.toolbox.ToolboxOptions( ...
         fullfile(root, "toolbox"), identifier, ...
         "ToolboxName", projectname);

      % The folder constructor lists every file, including hidden ones
      % the Finder or an editor drops (.DS_Store, .vscode/ contents).
      % A release must not ship them, so drop every file with a
      % dot-named segment anywhere below the shipped folder.
      files = string(opts.ToolboxFiles);
      toolboxfolder = string(fullfile(root, "toolbox"));
      hidden = false(numel(files), 1);
      for k = 1:numel(files)
         segments = split(erase(files(k), ...
            toolboxfolder + filesep), filesep);
         hidden(k) = any(startsWith(segments, "."));
      end
      opts.ToolboxFiles = files(~hidden);

      % The guide is what MATLAB opens after an install; the embedded
      % task carries it, so the fallback must set it too when the
      % conventional file exists.
      guide = fullfile(root, "toolbox", "gettingStarted.mlx");
      if isfile(guide)
         opts.ToolboxGettingStartedGuide = guide;
      end
   end

   % version.txt is the one place the version is written down, and its
   % one location is inside the shipped toolbox/ folder so every
   % package carries its own version source. A version.txt at the
   % project root is refused whether or not the shipped file exists:
   % alone it would set metadata an install cannot see, and next to
   % the shipped file it is a second apparent source that editing
   % would change nothing.
   if isfile(fullfile(root, "version.txt"))
      error("tbx:releaseoptions:versionOutsideShippedFolder", ...
         "version.txt sits at the project root of ""%s"" but the " + ...
         "one version source is toolbox/version.txt. Move the root " + ...
         "file there (or delete it if the shipped one already " + ...
         "exists) so installed code reports its own version.", root)
   end
   v = string(tbx.internal.version(root));
   opts.ToolboxVersion = erase(v, "v");

   % Versioned output under release/; GitHub release assets cannot carry
   % spaces, so they become underscores.
   mltbxname = strrep(string(opts.ToolboxName), " ", "_") + "_" + v ...
      + ".mltbx";
   opts.OutputFile = fullfile(root, "release", mltbxname);
end

function encoded = encodeidentifier(name)
   %ENCODEIDENTIFIER Encode a name injectively into [A-Za-z0-9-].
   %
   % Letters and digits pass through, "-" doubles to "--", and every
   % other character becomes "-" plus its two-lowercase-hex code, so
   % the original name is recoverable and two distinct names can never
   % encode to the same identifier.

   arguments
      name (1,1) string
   end

   % Two-hex escapes are unambiguous only for single-byte code units;
   % a unit above 0xFF would emit wider hex and break the fixed-width
   % decode, so non-ASCII names are refused rather than encoded
   % ambiguously.
   if any(double(char(name)) > 127)
      error("tbx:releaseoptions:nonAsciiProjectName", ...
         "Project name ""%s"" contains non-ASCII characters, which " + ...
         "the fallback identifier encoding does not support. Rename " + ...
         "the project folder or add an embedded Package Toolbox " + ...
         "task that carries an explicit identifier.", name)
   end

   % The pass-through set is exactly ASCII [A-Za-z0-9]; isstrprop would
   % also pass non-ASCII alphanumerics, which identifiers reject.
   chars = char(name);
   parts = strings(1, numel(chars));
   for k = 1:numel(chars)
      c = chars(k);
      if ismember(c, ['A':'Z', 'a':'z', '0':'9'])
         parts(k) = string(c);
      elseif c == '-'
         parts(k) = "--";
      else
         parts(k) = "-" + lower(string(dec2hex(double(c), 2)));
      end
   end
   encoded = join(parts, "");
end
