function proj = projectfile(buildOption)
   %PROJECTFILE Create or converge the matfunclib hub MATLAB Project.
   %
   %    projectfile()
   %    projectfile("create")
   %    proj = projectfile("create")
   %
   % Description
   %
   %  Generates every MATLAB Project in this repository: first the 20
   %  sub-library Projects, then the hub Project at the repository root
   %  that references them. matfunclib is a metarepo of independent
   %  libraries, so the hub imports no source files and carries the
   %  references. Each sub-library carries its own code folders.
   %  Opening the hub therefore puts every library on the MATLAB path
   %  through its Referenced Projects.
   %
   %  Generation runs leaves-first because addReference requires a
   %  target that is already an openable Project. Every call converges:
   %  re-running adds no file and no reference, and a sub-library
   %  dropped from SUBLIBRARIES below is removed from the hub's
   %  reference set on the next run.
   %
   %  This file lists the hub's sub-libraries. Each pair in
   %  SUBLIBRARIES is a folder name and a Project name. MATLAB writes
   %  the .prj filename from the Project name, so the CamelCase
   %  spelling here keeps LibRaster.prj named LibRaster.prj.
   %
   %  Run it from the repository root. MATLAB resolves the current
   %  folder before the path, so the root file wins over the toolbox
   %  template's own projectfile.m when both are on the path. The
   %  addpath call makes the run work in a session that has no startup
   %  file, such as a fresh clone:
   %
   %     matlab -nodisplay -nosplash -batch \
   %        "addpath(genpath('manager')); projectfile('create')"
   %
   % Inputs
   %
   %  BUILDOPTION - "create" (the only supported operation, and the
   %  default): create or converge every Project in the repository.
   %
   % Outputs
   %
   %  PROJ - The open hub matlab.project.Project. The caller closes it.
   %
   % See also: createhubproject, createMatlabProject

   arguments
      buildOption (1,1) string ...
         {mustBeMember(buildOption, "create")} = "create"
   end

   % The hub composition: folder name, then the Project name MATLAB
   % writes the .prj from. These 20 folders are the hub's Referenced
   % Projects. The other root folders (demos, dependencies, libweb,
   % private, sandbox, testbed, validators) are not Projects and are
   % deliberately absent.
   %
   % toolbox/ is absent for a different reason. It is the toolbox
   % template mkproject stamps into new projects. copytoolboxtemplate
   % refuses to copy a template that carries a root .prj or a
   % resources/ folder, because that state would merge into the
   % destination project. Generating a Project there would break every
   % future mkproject call. The hub therefore references 20 folders
   % where the July 2024 reference list held 21.
   SUBLIBRARIES = [ ...
      "functools",  "FuncTools"; ...
      "libarrays",  "LibArrays"; ...
      "libcells",   "LibCells"; ...
      "libdata",    "LibData"; ...
      "libhydro",   "LibHydro"; ...
      "liblogic",   "LibLogic"; ...
      "libmath",    "LibMath"; ...
      "liboctave",  "LibOctave"; ...
      "libplot",    "LibPlot"; ...
      "libraster",  "LibRaster"; ...
      "libspatial", "LibSpatial"; ...
      "libstats",   "LibStats"; ...
      "libstruct",  "LibStruct"; ...
      "libsys",     "LibSys"; ...
      "libtable",   "LibTable"; ...
      "libtext",    "LibText"; ...
      "libtime",    "LibTime"; ...
      "libunits",   "LibUnits"; ...
      "manager",    "Manager"; ...
      "templates",  "Templates"];

   % Scratch trees hold work in progress that must never reach the
   % Project path; 14 of these sub-libraries carry a testbed folder.
   % These are the same two names the template's projectfile.m
   % excludes.
   IGNOREDFOLDERS = ["sandbox", "testbed"];

   % The hub root is where this file sits, not wherever it was called
   % from, so a call from a subfolder still generates the same tree.
   projectFolder = fileparts(mfilename('fullpath'));

   % One operation today. The switch keeps the interface the template's
   % projectfile.m uses, where the option selects the operation.
   switch buildOption
      case "create"
         proj = createhubproject(projectFolder, SUBLIBRARIES, ...
            projectName="MatFuncLib", ...
            ignoredSubFolders=IGNOREDFOLDERS);
   end

   % Return the open hub only when asked, so a scripted call does not
   % echo the object.
   if ~nargout
      clear proj
   end
end
