function list = gettbdirectorylist(varargin)
   %GETTBDIRECTORYLIST Get a list of toolbox directories.
   %
   %  list = gettbdirectorylist()
   %    Returns the names of stand-alone toolbox folders directly under
   %    MATLAB_TOOLBOX_PATH (excluding the 'libraries' subdirectory).
   %
   %  list = gettbdirectorylist(LIBNAME)
   %    Returns the names of toolbox folders inside
   %    MATLAB_TOOLBOX_PATH/libraries/LIBNAME.
   %
   % Filesystem layout expected:
   %   MATLAB_TOOLBOX_PATH/
   %     <toolbox>/           <- stand-alone toolbox (no-arg return)
   %     libraries/
   %       <libname>/         <- library folder (is itself a toolbox entry)
   %         <toolbox>/       <- library toolbox (returned by gettbdirectorylist(libname))
   %
   % Note: gettbnamelist returns the names of toolboxes in the toolbox
   % directory, so it should be used in functionsignatures for functions
   % that work with valid registered toolboxes. This function lists folders
   % on the filesystem and is used by addtoolbox and similar utilities.
   %
   % See also: readtbdirectory, gettbnamelist, addtoolbox

   tbroot = gettbsourcepath();  % getenv('MATLAB_TOOLBOX_PATH')

   if nargin < 1
      % Return stand-alone toolbox folder names (immediate children of
      % MATLAB_TOOLBOX_PATH, excluding the 'libraries' folder itself).
      entries = rmdotfolders(dir(tbroot));
      entries = entries([entries.isdir]);
      names = string({entries.name}');
      list = names(names ~= "libraries");

   else
      % Return toolbox folder names inside MATLAB_TOOLBOX_PATH/libraries/<libname>.
      library = validatetoolbox(varargin{1}, mfilename, 'library', 1);
      libpath = fullfile(tbroot, 'libraries', library);
      tblist = rmdotfolders(dir(libpath));
      list = string({tblist([tblist.isdir]).name}');
   end
end
