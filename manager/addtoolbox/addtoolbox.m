function varargout = addtoolbox(tbname,varargin)
   % ADDTOOLBOX Add toolbox to toolbox directory.
   %
   %    addtoolbox(tbname)
   %    toolboxes = addtoolbox(tbname)
   %    toolboxes = addtoolbox(tbname, 'dryrun', true)
   %    toolboxes = addtoolbox(tbname, 'library', name)
   %    toolboxes = addtoolbox(tbname, 'posthook', 'activate')
   %
   %  Description
   %
   %    ADDTOOLBOX(TBNAME) Adds TBNAME to the toolbox directory, checkS if the
   %    toolbox source code exists in the user toolbox source code directory,
   %    and whether the toolbox already exists in the directory.
   %
   %    ADDTOOLBOX(TBNAME, LIBRARY=LIBNAME) Adds TBNAME located in sub-folder
   %    (library) LIBNAME to the toolbox directory, as above. Use this option
   %    to group toolboxes within libraries such as 'stats', 'hydro', etc.
   %
   %    ADDTOOLBOX(_, DRYRUN=TRUE) Prints a message about what will happen
   %    if DRYRUN=FALSE but does not perform the operation.
   %
   %    ADDTOOLBOX(_, POSTHOOK="activate") Adds the toolbox to the current path
   %    and cd's into the source code folder.
   %
   %  Examples
   %
   %    addtoolbox('test', libary='stats', posthook='activate') will add an
   %    entry to the toolbox directory for toolbox 'test' located in libary
   %    'stats' and will attempt to cd into the folder located at:
   %    [getenv('MATLABSOURCEPATH') filesep libname filesep tbname]
   %
   %     See also: activate deactivate renametoolbox isactive
   %
   % UPDATES
   % 23 May 2024, moved activate to oncleanup and added try-catch around the
   % main writedirectory step
   % 23 May 2024, added "dryrun" name-value and renamed "postadd" to "posthook"
   % 7 Feb 2023, tbpath method updated to work for both top-level and sublib
   % dirs, but assumes args.library is empty by default. changed variable names
   % from 'tblibrary' and 'tbactivate' to 'library' and 'postadd'

   % TODO: allow source code to not exist in the specified "library" and if so,
   % move it from where it exists to the library folder.

   % PARSE INPUTS
   kwargs = parseinputs(tbname, mfilename, varargin{:});

   % Read the toolbox directory into memory
   toolboxes = readtbdirectory(gettbdirectorypath());

   % Set the path to the toolbox source code (works if args.library is empty)
   tbpath = fullfile(gettbsourcepath(), kwargs.library, kwargs.tbname);

   % Add the toolbox to the end of directory
   tbidx = height(toolboxes) + 1;

   % Regardless of sub-libs, we still want to match this
   if any(ismember(toolboxes.name, kwargs.tbname))
      error('toolbox already in directory');
   end

   % Print the message
   printUserMessage(kwargs.tbname, kwargs.library, tbpath)

   success = false;
   if not(kwargs.dryrun)
      try
         toolboxes(tbidx, :) = {kwargs.tbname, tbpath, false, kwargs.library};
         writetbdirectory(toolboxes);
         success = true;
      catch e
         rethrow(e)
      end
   end

   if success
      job = onCleanup(@() posthook(kwargs));
   end

   % Handle output
   switch nargout
      case 1
         varargout{1} = toolboxes;
   end
end

function posthook(kwargs)
   % Activate the toolbox if requested
   if strcmp(kwargs.posthook, 'activate')
      activate(kwargs.tbname, 'goto');
   end
end

function printUserMessage(tbname, libraryname, tbpath)
   % Print message about adding the toolbox
   fprintf(1, '\nadding "%s" to toolbox directory in library "%s"...\n', ...
      tbname, libraryname);
   fprintf(1, 'toolbox source code saved in: "%s" \n', tbpath);
end

%%
function kwargs = parseinputs(tbname, funcname, varargin)

   % Note: char.empty() defaults are for str concatenation in main.
   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = funcname;
      parser.CaseSensitive = false;
      parser.KeepUnmatched = true;
      parser.addRequired('tbname', @isscalartext);
      parser.addParameter('library', char.empty(), @validateLibraryName);
      parser.addParameter('posthook', char.empty(), @validOption);
      parser.addParameter('dryrun', false, @islogicalscalar)
   end
   parser.parse(tbname, varargin{:});
   kwargs = parser.Results;

   tbname = char(tbname);
   kwargs.library = char(kwargs.library);
   kwargs.posthook = char(kwargs.posthook);

   if isempty(kwargs.library)
      % not implemented
   end
end

function tf = validOption(opt)
   tf = any(validatestring(opt, {'activate'})) && isscalartext(opt);
end
