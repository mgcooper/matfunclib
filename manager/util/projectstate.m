function state = projectstate(folder)
   %PROJECTSTATE Classify a folder's MATLAB Project state.
   %
   %    state = projectstate(folder)
   %
   % Description
   %
   %  Returns one of four states, from folder existence and the two
   %  on-disk markers a MATLAB Project has (a root MATLAB Project .prj
   %  file and the resources/project tree):
   %
   %    "missing"  - the folder does not exist (for example a project
   %                 directory entry whose folder was deleted or
   %                 moved).
   %    "project"  - both markers present; openProject can open it.
   %    "none"     - neither marker present; createProject can create it.
   %    "orphaned" - one marker without the other. openProject fails on
   %                 such a folder, so a caller must not treat it as a
   %                 Project, and creating over it risks mixing stale
   %                 state into the new Project. Repair means deleting
   %                 the stale marker and regenerating.
   %
   %  createMatlabProject and addprojectrefs share this check so a
   %  broken folder is reported the same way at creation time and at
   %  reference-validation time.
   %
   % See also: createMatlabProject, addprojectrefs

   arguments
      folder (1,1) string
   end

   % A validator would throw here and rob callers of their own
   % diagnostic for stale directory entries, so absence is a state.
   if ~isfolder(folder)
      state = "missing";
      return
   end

   % The two markers: a root .prj file that is a MATLAB Project file,
   % and the resources/project tree createProject writes. The .prj
   % extension is shared with Deployment configurations (icom-msd's
   % toolboxPackaging.prj) and ESRI coordinate-system files
   % (templates/geoprojtemplate.prj), so the file's content decides,
   % not its extension: counting a foreign .prj would classify an
   % ordinary folder as orphaned Project state.
   found = dir(fullfile(folder, "*.prj"));
   hasprj = false;
   for k = 1:numel(found)
      if ismatlabprojectfile(fullfile(found(k).folder, found(k).name))
         hasprj = true;
         break
      end
   end
   hasresources = isfolder(fullfile(folder, "resources", "project"));

   if hasprj && hasresources
      state = "project";
   elseif ~hasprj && ~hasresources
      state = "none";
   else
      state = "orphaned";
   end
end

%% local functions

function tf = ismatlabprojectfile(file)
   %ISMATLABPROJECTFILE Return true for a MATLAB Project .prj file.
   %
   % A MATLAB Project file is XML whose root element is MATLABProject.
   % A Deployment configuration names deployment-project instead, and
   % an ESRI coordinate-system file is not XML at all. The whole file
   % is read because an XML prolog has no length limit: a comment or a
   % doctype can run past any fixed header size, and truncating one
   % leaves markup the root-element match would misread. A .prj is a
   % configuration file, so the largest in this portfolio is tens of
   % kilobytes.

   arguments
      file (1,1) string
   end

   tf = false;
   fid = fopen(file, "r");
   % fopen fails on a folder named *.prj and on an unreadable file,
   % neither of which is Project state.
   if fid < 0
      return
   end
   % A closeable file must close on every path, including a read error.
   cleanup = onCleanup(@() fclose(fid));
   contents = string(fread(fid, Inf, "*char").');

   % The first element name decides, so remove the prolog first:
   % comments, the XML declaration, and any doctype. A comment can hold
   % markup that looks like a root element.
   % An unterminated construct leaves its opening delimiter in place,
   % and the name character class below rejects the ? and ! that
   % follow it.
   contents = regexprep(contents, "<!--.*?-->", "");
   contents = regexprep(contents, "<\?.*?\?>", "");
   contents = regexprep(contents, "<!\w+.*?>", "");

   % A UTF-8 byte order mark reaches the text as one character, and it
   % sits before the root element, so remove it.
   contents = erase(contents, char(65279));

   % What remains must START with the root element. An ESRI file that
   % names the markup later in the file stays foreign. The comparison
   % is exact as well: a substring test would accept
   % <MATLABProjectBackup/>.
   token = regexp(strip(contents), "^<\s*([A-Za-z_][\w.:-]*)", ...
      "tokens", "once");
   tf = ~isempty(token) && token(1) == "MATLABProject";
end
