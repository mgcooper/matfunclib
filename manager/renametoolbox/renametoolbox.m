function varargout = renametoolbox(oldtbname,newtbname,varargin)
   %RENAMETOOLBOX Rename toolbox and optionally move the source folder.
   %
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'LIBRARY', LIBRARYNAME)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'RENAMESOURCE', TRUE)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'MOVESOURCE', TRUE)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'FORCE', TRUE)
   %
   %  With 'RENAMESOURCE', TRUE, renametoolbox moves the source folder
   %  (after a prompt unless 'FORCE', TRUE) and rewrites the registry row
   %  only when the move completes. A declined prompt leaves the folder
   %  and the row unchanged and warns matfunclib:renametoolbox:moveDeclined.
   %  A failed move raises matfunclib:renametbsourcedir:moveFailed.
   %
   % See also: rmtoolbox, addtoolbox

   % UPDATES
   % 23 May 2024, added onCleanup when rewriting the directory
   % 23 May 2024, fix: remove unused "movesource" flag in return arguments from
   % parseinputs to main function (movesource was therefore incorrectly being
   % assigned the value of "force" in the main function)
   % 23 May 2024, made "library" a name-value parameter instead of positional
   % 11 Apr 2023, support for sublibs via 'libary' optional argument 11
   % Apr 2023, support for moving source to sublib via 'movesource' namevalue

   % PARSE INPUTS
   [oldtbname, newtbname, libraryname, renamesource, force, dryrun] = ...
      parseinputs(oldtbname, newtbname, mfilename, varargin{:});

   % MAIN FUNCTION

   % confirm the toolbox exists
   oldtbname = validatetoolbox(oldtbname, mfilename, 'OLDTBNAME', 1);

   % readtbdirectory errors when neither the CSV nor a backup can be read
   % and never returns an empty table, so the write-back below cannot
   % erase a good registry with an empty table (matfunclib-b7u item 2).
   % writetbdirectory refuses an empty table too.
   % read the toolbox directory into memory
   toolboxes = readtbdirectory(gettbdirectorypath());

   % get the logical index for the toolbox entry
   tbidx = findtbentry(toolboxes,oldtbname);

   % set the path to the toolbox source code (works if args.library is empty)
   oldtbpath = gettbsourcepath(oldtbname);

   % build the new toolbox path
   newtbpath = fullfile(gettbsourcepath, libraryname, newtbname);

   % print the message
   printUserMessage(oldtbname, libraryname, newtbname, ...
      oldtbpath, newtbpath)

   % perform the operation if this is not a dryrun
   if not(dryrun)

      % rename the source directory if requested
      moved = renametbsourcedir(renamesource, oldtbpath, newtbpath, force);

      % When the user declines a requested move, the folder stays where
      % it is, so the registry row must not point at a path that does
      % not exist (audit MEDIUM 17). The output below still returns the
      % unchanged table. A failed move errors inside renametbsourcedir
      % and never reaches this line.
      if renamesource && ~moved
         warning('matfunclib:renametoolbox:moveDeclined', ...
            'renametoolbox: source move declined; %s left unchanged.', ...
            oldtbname);
      else
         % only update the toolbox if the rename (and/or move) is successful
         job = onCleanup(@() updateToolboxDirectory( ...
            toolboxes, tbidx, newtbname, newtbpath, libraryname));
      end
   end

   % output
   switch nargout
      case 1
         varargout{1} = toolboxes;
   end
end

%% SIDE EFFECTS
function updateToolboxDirectory( ...
      toolboxes, tbidx, newtbname, newtbpath, libraryname)
   % set the toolbox directory entries
   toolboxes.name{tbidx} = newtbname;
   toolboxes.source{tbidx} = newtbpath;
   toolboxes.library{tbidx} = libraryname;

   % rewrite the toolbox directory
   writetbdirectory(toolboxes);
end

%% USER MESSAGE
function printUserMessage(oldtbname, libraryname, newtbname, ...
      oldtbpath, newtbpath)

   % Print message about renaming the toolbox
   fprintf(1, '\nrenaming "%s" toolbox "%s/%s" \n', ...
      oldtbname, libraryname, newtbname);

   % Print message about moving the toolbox source code
   if string(fileparts(oldtbpath)) ~= string(fileparts(newtbpath))
      fprintf(1, '\nmoving "%s" toolbox from "%s" to:\n "%s" \n', ...
         oldtbname, oldtbpath, newtbpath);
   end
end

%% INPUT PARSER
function [oldtbname, newtbname, libraryname, renamesource, force, dryrun] = ...
      parseinputs(oldtbname, newtbname, mfilename, varargin)

   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = mfilename;
      parser.CaseSensitive = false;
      parser.KeepUnmatched = true;
      parser.addRequired('oldtbname', @isscalartext);
      parser.addRequired('newtbname', @isscalartext);
      parser.addParameter('library', char.empty(), @validateLibraryName);
      parser.addParameter('renamesource', false, @islogicalscalar);
      parser.addParameter('movesource', false, @islogicalscalar);
      parser.addParameter('force', false, @islogicalscalar);
      parser.addParameter('dryrun', false, @islogicalscalar);
   end
   parser.parse(oldtbname, newtbname, varargin{:});
   force = parser.Results.force;
   dryrun = parser.Results.dryrun;
   oldtbname = parser.Results.oldtbname;
   newtbname = parser.Results.newtbname;
   movesource = parser.Results.movesource;
   libraryname = parser.Results.library;
   renamesource = parser.Results.renamesource;

   % 'renaming' is the same as 'moving' so combine them here
   renamesource = movesource | renamesource;

   % parsing below only needed b/c NEWTBNAME does not exist in toolbox
   % directory, otherwise validateToolbox would do all of this work. If any of
   % the inputs are non-scalar strings, then convertStringsToChars will convert
   % them to cellstr, which is why the iscell check is performed.

   % convert strings to chars so path-joining functions work as expected
   [oldtbname, newtbname, libraryname] = convertStringsToChars( ...
      oldtbname, newtbname, libraryname);
   oldtbname = validatetoolbox(oldtbname,mfilename,'OLDTBNAME',1);

   if iscell(oldtbname) || iscell(newtbname) || iscell(libraryname)
      error('MATFUNCLIB:renametoolbox:nonScalarToolboxName', ...
         'toolbox names must be scalar text')
   end
end
