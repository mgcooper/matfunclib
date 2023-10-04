function varargout = updatetbdirectory(option, varargin)
   %UPDATETBDIRECTORY Updates the toolbox directory based on existing paths.
   %
   % NOTE: this needs to be updated
   %
   % TOOLBOXES = UPDATETBDIRECTORY('paths') Traverses the toolbox directory and
   % checks if the source path exists for each toolbox at the top-level or
   % within sub-libraries. If the source path is found, it is updated in the
   % directory. If not, the corresponding pathexists field is set to false.
   %
   % TOOLBOXES = UPDATETBDIRECTORY('paths', 'dryrun', true) returns the toolbox
   % table with missing toolbox paths set to 'missing' but does not remove them
   % from the table and does not rewrite the table.
   %
   % Example
   %  updatetbdirectory('paths');
   %
   % See also GETFOLDERLIST, GETTBSOURCEPATH, RMTOOLBOX, ADDTOOLBOX

   % PARSE INPUTS
   narginchk(1,3)

   opts.dryrun = true;
   if nargin > 2
      [args, pairs, nargs] = parseparampairs(varargin);
      opts = cell2struct(pairs(2:2:end), pairs(1:2:end-1), 2);
   end

   % Only one option is available for now
   assert(strcmp(option, 'paths'), ...
      "Invalid option. The only available option is 'paths'.");

   % get the toolbox directory
   toolboxes = readtbdirectory(gettbdirectorypath());

   % add a column for the library
   toolboxes.library = toolboxes.name;

   % convert toolbox names to string array for convenience
   allnames = string(toolboxes.name).';

   for tbname = allnames

      % use gettbsourcepath because it handles the trailing slash
      tbpath = gettbsourcepath(tbname);

      % default values for the sublib and path
      library = char(tbname);
      newpath = tbpath;

      if isfolder(tbpath)
         % the toolbox path is OK, add the library
         if ~strcmp(fileparts(tbpath), gettbsourcepath())
            [~, library] = fileparts(fileparts(tbpath));
         end
      else
         newpath = 'missing';

         % check if the toolbox is in the top-level
         if isfolder(fullfile(gettbsourcepath(), tbname))
            newpath = fullfile(gettbsourcepath(), tbname);
         else
            % get the library list and find the match for tbname within it
            sublibs = listfolders(gettbsourcepath(), 1, 'relativepaths');
            matched = false(size(sublibs));
            for ii = 1:length(sublibs)
               sublibFolders = split(sublibs{ii}, '/');
               matched(ii) = any(strcmp(tbname, sublibFolders));
            end
            % get the sublib (tb parent) folder name
            if any(matched)
               library = char(fileparts(sublibs{matched}));
               newpath = fullfile(gettbsourcepath(), library, tbname);
            end
         end
      end

      toolboxes.library{allnames==tbname} = char(library);
      toolboxes.source{allnames==tbname} = char(newpath);
   end

   % remove missing if not dryrun
   if opts.dryrun == false
      toolboxes(strcmp(toolboxes.source, 'missing'), :) = [];
      writetbdirectory(toolboxes);
   end

   switch nargout
      case 1
         varargout{1} = toolboxes;
   end


   %       % found or not, remove the toolbox from the directory
   %       % if found, re-add it
   %       if found
   %          if opts.dryrun == true
   %             toolboxes.source{allnames==tbname} = char(newpath);
   %             toolboxes.pathexists(allnames==tbname) = true;
   %          else
   %             rmtoolbox(tbname);
   %             toolboxes = addtoolbox(tbname, sublib);
   %          end
   %       else
   %          if opts.dryrun == true
   %             toolboxes(allnames==tbname, :) = [];
   %          else
   %             rmtoolbox(tbname);
   %          end
   %       end

   % original method fails when tbname is a substr of a subfolder
   % find the match for tbname within sublibs
   % matched = ~cellfun(@isempty, strfind(sublibs, tbname)); %#ok<STRCLFH>
   % revisit to see if this works
   % matched = ~cellfun(@(s) any(strcmp(tbname, split(s, '/'))), sublibs);

   % this would have been initialized at the bginning
   % add a column indicating if the path is found
   % toolboxes.pathexists = true(height(toolboxes), 1);
   % flag to indicate if the toolbox folder exists
   % found = false(numel(allnames), 1);
   % and this would have been in the else bloc
   % set the flag false
   % toolboxes.pathexists(allnames==tbname) = false;
end
