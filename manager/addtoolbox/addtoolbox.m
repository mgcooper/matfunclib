function varargout = addtoolbox(tbname,varargin)
   % ADDTOOLBOX Add toolbox to toolbox directory.
   %
   %     ADDTOOLBOX(TBNAME) Adds TBNAME to the toolbox directory, checkS if the
   %     toolbox source code exists in the user toolbox source code directory,
   %     and whether the toolbox already exists in the directory.
   %
   %     ADDTOOLBOX(TBNAME, LIBNAME) Adds TBNAME located in sub-folder (library)
   %     LIBNAME to the toolbox directory, as above. Use this option to group
   %     toolboxes within libraries such as 'stats', 'hydro', etc.
   %
   %     ADDTOOLBOX(_, 'activate') adds the toolbox to the current path and cd's
   %     into the source code folder.
   %
   %     Examples
   %
   %     addtoolbox('test','stats','activate') will add an entry to the toolbox
   %     directory for toolbox 'test' located in libary 'stats' and will attempt
   %     to cd into the folder located at: [getenv('MATLABSOURCEPATH') filesep
   %     libname filesep tbname]
   %
   %     See also: activate deactivate renametoolbox isactive
   %
   % UPDATES
   % 7 Feb 2023, tbpath method updated to work for both top-level and sublib dirs,
   % but assumes args.library is empty by default. changed variable names from
   % 'tblibrary' and 'tbactivate' to 'library' and 'postadd'

   % PARSE INPUTS
   args = parseinputs(tbname, mfilename, varargin{:});

   % Read the toolbox directory into memory
   toolboxes = readtbdirectory(gettbdirectorypath());

   % Set the path to the toolbox source code (works if args.library is empty)
   tbpath = fullfile(gettbsourcepath, args.library, args.tbname);

   % Add the toolbox to the end of directory
   tbidx = height(toolboxes) + 1;

   % Regardless of sub-libs, we still want to match this
   if any(ismember(toolboxes.name, args.tbname))
      error('toolbox already in directory');
   else
      toolboxes(tbidx,:) = {args.tbname, tbpath, false, args.library};

      disp(['adding ' args.tbname ' to toolbox directory']);

      writetbdirectory(toolboxes);
   end

   % Activate the toolbox if requested
   if string(args.postadd)=="activate"
      activate(args.tbname,'goto');
   end

   % Handle output
   switch nargout
      case 1
         varargout{1} = toolboxes;
   end
end

%% INPUT PARSER
function args = parseinputs(tbname, funcname, varargin)

   validlibs = @(x) any(validatestring(x, cellstr(gettbdirectorylist)));
   validopts = @(x) any(validatestring(x,{'activate'}));
   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = funcname;
      parser.CaseSensitive = false;
      parser.KeepUnmatched = true;
      parser.addRequired('tbname', @ischar);
      parser.addOptional('library', '', validlibs); % default value must be ''
      parser.addOptional('postadd', '', validopts);
   end
   tbname = convertStringsToChars(tbname);
   parser.parse(tbname,varargin{:});
   args = parser.Results;
   if isempty(args.library)

   end
end

% % NOTE on tbpath method - gettbsourcepath with no input returns the matlab
% source directory so if args.library is empty then the new method in the main
% code works for both cases, sub-library or no sublibrary. This is the old
% method that is slightly safer b/c gettbsourcepath loads the file and finds the
% path in the table.

% if ~isempty(args.library)
%    tbpath = fullfile(gettbsourcepath,args.library,args.tbname);
% else
%    tbpath = gettbsourcepath(args.tbname);
% end

%% removed json signature file option

% % instead of this, use choices=gettbnamelist
%
% % add it to the json directory choices for function 'activate'
% addtojsondirectory(toolboxes,tbidx,'activate');
%
% % repeat for 'deactivate'
% addtojsondirectory(toolboxes,tbidx,'deactivate');

% function addtojsondirectory(toolboxes,tbidx,directoryname)
% jspath      = gettbjsonpath(directoryname);
% wholefile   = readtbjsonfile(jspath);
% % replace the most recent entry with itself + the new one
% tbfind      = sprintf('''%s''',toolboxes.name{tbidx-1});
% tbreplace   = sprintf('%s,''%s''',tbfind,toolboxes.name{tbidx});
% wholefile   = strrep(wholefile,tbfind,tbreplace);
% % write it over again
% writetbjsonfile(jspath,wholefile)
