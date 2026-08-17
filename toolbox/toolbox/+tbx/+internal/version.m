function v = version(root)
   %VERSION Read version.txt in the project root directory.
   %
   %  v = tbx.internal.version()
   %  v = tbx.internal.version(root)
   %
   % Returns the version string from version.txt, whitespace-stripped,
   % with its leading "v" intact (for example "v0.1.0"). version.txt
   % lives inside the shipped toolbox folder, the ONE location, so a
   % packaged install carries its own version source and this helper
   % reads the same file in the repository and after installation
   % (toolboxpath self-locates the shipped folder from this file's
   % position). With a ROOT argument (a project root folder), the
   % shipped location <root>/toolbox/version.txt is read.
   %
   % Falls back to "v0.1.0" only when no version.txt exists; a read
   % failure on an existing file (permissions, I/O) raises, because
   % substituting the fallback there would let a release package and
   % verify the wrong version. releaseoptions refuses to package a
   % project that keeps version.txt outside the shipped folder, so the
   % fallback cannot mask a misplaced file at release time.
   %
   % Note: fileread takes one filename argument; join the folder and
   % filename with fullfile before the call.
   %
   % See also: tbx.internal.releaseoptions

   arguments
      root string = string.empty()
   end

   if isempty(root)
      versionfile = string(fullfile(toolboxpath(), 'version.txt'));
   else
      versionfile = string(fullfile(root, 'toolbox', 'version.txt'));
   end

   if isfile(versionfile)
      v = strtrim(fileread(versionfile));
   else
      v = 'v0.1.0';
   end
end
