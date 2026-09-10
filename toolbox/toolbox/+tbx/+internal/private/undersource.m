function tf = undersource(folder, root)
   %UNDERSOURCE True when FOLDER is ROOT or lies below it.
   %
   %  tf = undersource(folder, root)
   %
   % Description
   %  undersource compares on folder boundaries, so "/tmp/src-copy" is
   %  not under "/tmp/src", which a substring test would accept. It
   %  normalizes both paths first: either separator counts, "." segments
   %  go, and a ".." segment removes the segment before it, so
   %  "/tmp/src/../x" is not under "/tmp/src" either. It ignores a
   %  trailing separator on ROOT. On Windows the comparison ignores
   %  letter case, as the file system does. FOLDER may be a string array,
   %  and TF has the same size.
   %
   % See also: installRequiredFiles, getRequiredFiles

   arguments
      folder string
      root (1, 1) string
   end

   % arrayfun over an empty string array returns an empty double, which
   % the comparison below rejects, so an empty input answers itself.
   tf = false(size(folder));
   if isempty(folder)
      return
   end

   root = normalize(root);
   folder = arrayfun(@normalize, folder);
   % Windows paths are case-insensitive, so "c:\Repo" and "C:\repo" name
   % one folder. Fold case there and nowhere else. A Windows directory
   % made case-sensitive (an NTFS per-directory flag) is outside this
   % rule and compares as if it folded.
   if ispc
      root = lower(root);
      folder = lower(folder);
   end
   % A folder is under a root only when both are the same kind of path
   % (POSIX-rooted, drive-rooted, UNC, or relative). Two relative paths
   % must also climb the same number of ".." above their start: "../../x"
   % is not under "..", and the drive-rooted "C:/x" is not under the
   % relative "C:". The prefix to match is then the root plus one
   % separator. A file-system root such as "/" already ends with its only
   % separator, so none is added, or "//" would match nothing. A relative
   % root that normalizes to nothing ("." or "") is the current folder:
   % every relative folder that climbs nowhere is under it.
   [rootKind, rootDepth] = kind(root);
   [folderKind, folderDepth] = arrayfun(@kind, folder);
   sameKind = folderKind == rootKind & folderDepth == rootDepth;
   if strlength(root) == 0
      tf = sameKind;
      return
   end
   prefix = root;
   if ~endsWith(prefix, "/")
      prefix = prefix + "/";
   end
   tf = sameKind & (folder == root | startsWith(folder, prefix));
end

function [k, depth] = kind(path)
   %KIND The path's root kind and, for a relative path, its ".." depth.
   %
   % K is "unc", "drive", "posix", or "relative". DEPTH counts the
   % leading ".." segments of a normalized relative path and is 0 for a
   % rooted one.

   depth = 0;
   if startsWith(path, "//")
      k = "unc";
   elseif ~isempty(regexp(path, '^[A-Za-z]:/', 'once'))
      k = "drive";
   elseif startsWith(path, "/")
      k = "posix";
   else
      k = "relative";
      segments = split(path, "/");
      depth = find(segments ~= "..", 1) - 1;
      if isempty(depth)
         depth = numel(segments);
      end
      % A path that normalized to nothing has no segments at all.
      if strlength(path) == 0
         depth = 0;
      end
   end
end

function path = normalize(path)
   %NORMALIZE Resolve "." and ".." segments and use one separator.
   %
   % A rooted path keeps its root: "/" for a POSIX path, "C:/" for a
   % Windows drive root, "//server/share" for a UNC share. ".." never
   % climbs above that root. A relative path keeps an unmatched ".." as a
   % segment, and a drive-relative path such as "C:src" is one ordinary
   % segment, not a root.

   arguments
      path (1, 1) string
   end

   % MATLAB string literals take no escapes, so a single backslash is
   % written "\" and "\\" is two characters (the UNC prefix). regexp on a
   % string returns "" for no match, which isempty does not treat as
   % empty, so the code takes the drive match as char and tests its length.
   unc = startsWith(path, ["//", "\\"]);
   drive = char(regexp(char(path), '^[A-Za-z]:(?=[/\\])', 'match', 'once'));
   absolute = startsWith(path, ["/", "\"]) || ~isempty(drive);

   % kept holds the resolved segments in its first n slots. It is sized
   % for every segment, since a resolved path is never longer. base is the
   % number of leading segments that form the root and are never popped:
   % the drive for "C:/", the server and share for a UNC path.
   segments = regexp(path, '[/\\]+', 'split');
   segments = segments(segments ~= "" & segments ~= ".");
   kept = strings(numel(segments), 1);
   n = 0;
   base = 0;
   if ~isempty(drive)
      n = 1;
      base = 1;
      kept(1) = string(drive);
      segments = segments(2:end);
   elseif unc
      base = min(2, numel(segments));
      n = base;
      kept(1:base) = segments(1:base);
      segments = segments(base + 1:end);
   end
   for segment = segments
      if segment == ".."
         if n > base && kept(n) ~= ".."
            n = n - 1;
         elseif ~absolute
            n = n + 1;
            kept(n) = "..";
         end
      else
         n = n + 1;
         kept(n) = segment;
      end
   end
   path = strjoin(kept(1:n), "/");
   if unc
      path = "//" + path;
   elseif ~isempty(drive)
      % The drive root itself is "C:/", so it never equals the
      % drive-relative "C:".
      if n == base
         path = path + "/";
      end
   elseif absolute
      path = "/" + path;
   end
end
