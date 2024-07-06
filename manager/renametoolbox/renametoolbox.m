function varargout = renametoolbox(oldtbname,newtbname,varargin)
   %RENAMETOOLBOX Rename toolbox and optionally move the source folder.
   %
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'LIBRARY', LIBRARYNAME)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'RENAMESOURCE', TRUE)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'MOVESOURCE', TRUE)
   %  TOOLBOXES = RENAMETOOLBOX(OLDTBNAME, NEWTBNAME, 'FORCE', TRUE)
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
      success = false;
      try
         renametbsourcedir(renamesource, oldtbpath, newtbpath, force)
         success = true;
      catch e
         rethrow(e)
      end

      % only update the toolbox if the rename (and/or move) is successful
      if success
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
   fprintf('\nrenaming "%s" toolbox "%s/%s" \n', ...
      oldtbname, libraryname, newtbname);

   % Print message about moving the toolbox source code
   if string(fileparts(oldtbpath)) ~= string(fileparts(newtbpath))
      fprintf('\nmoving "%s" toolbox from "%s" to:\n "%s" \n', ...
         oldtbname, oldtbpath, newtbpath);
   end
end

%% INPUT PARSER
function [oldtbname, newtbname, libraryname, renamesource, force, dryrun] = ...
      parseinputs(oldtbname, newtbname, mfilename, varargin)

   validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));
   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = mfilename;
      parser.CaseSensitive = false;
      parser.KeepUnmatched = true;
      parser.addRequired('oldtbname', @ischarlike);
      parser.addRequired('newtbname', @ischarlike);
      parser.addParameter('library', '', validlibs); % default value must be ''
      parser.addParameter('renamesource', false, @islogical);
      parser.addParameter('movesource', false, @islogical);
      parser.addParameter('force', false, @islogical);
      parser.addParameter('dryrun', false, @islogical);
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
