function varargout = listfiles(folderlist, opts)
   %LISTFILES List all files in folder and (optionally) subfolders.
   %
   % FILELIST = LISTFILES(FOLDERNAME)
   % FILELIST = LISTFILES(FOLDERLIST)
   % FILELIST = LISTFILES(_, 'ASLIST', TRUE)
   % FILELIST = LISTFILES(_, 'ASSTRUCT', TRUE)
   % FILELIST = LISTFILES(_, 'ASSTRING', TRUE)
   % FILELIST = LISTFILES(_, 'SUBFOLDERS', TRUE)
   % FILELIST = LISTFILES(_, 'FULLPATH', TRUE)
   % FILELIST = LISTFILES(_, 'MFILES', TRUE)
   % [FILELIST, NUMFILES] = LISTFILES(_)
   %
   % Description:
   %
   % FILELIST = LISTFILES(FOLDERNAME) Returns a directory structure in the
   % same format returned by DIR containing all files in directory FOLDERNAME.
   %
   % [FILELIST, NUMFILES] = LISTFILES(FOLDERNAME) Also returns the number of
   % files.
   %
   % FILELIST = LISTFILES(_, 'SUBFOLDERS', TRUE) Returns all files in all
   % subfolders of FOLDERNAME.
   %
   % FILELIST = LISTFILES(_, 'MFILES', TRUE) Only returns m-files.
   %
   % FILELIST = LISTFILES(_, 'ASLIST', TRUE) Returns a list of
   % filenames in a cell array rather than the default directory struct.
   %
   % FILELIST = LISTFILES(_, 'ASLIST', TRUE, 'ASSTRING', TRUE) Returns
   % a string array of filenames rather than the default directory struct.
   %
   % FILELIST = LISTFILES(_, 'ASLIST', TRUE, 'FULLPATHS', TRUE) Returns
   % fullpaths to each file in a cell array rather than the default directory
   % struct.
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper.
   %
   % See also: mfilename, mcallername, mfoldername, ismfile

   arguments
      folderlist (1,:) string = pwd()
      opts.subfolders (1,1) logical = false
      opts.asstruct (1,1) logical = true
      opts.aslist (1,1) logical = false
      opts.asstring (1,1) logical = false
      opts.fullpath (1,1) logical = false
      opts.mfiles (1,1) logical = false
   end

   % Create the list of files
   list = cellmap(@(folder) processOneFolder(folder, opts), folderlist);
   list = vertcat(list{:});
   
   % Parse outputs
   switch nargout
      case 1
         varargout{1} = list;
      case 2
         varargout{1} = list;
         varargout{2} = numel(list);
   end
end

%% Local Functions

function list = processOneFolder(folder, opts)
   
   % Get all sub folders
   if opts.subfolders == true
      list = rmdotfolders(dir(fullfile(folder, '**/*')));
   else
      list = rmdotfolders(dir(fullfile(folder)));
   end
   list = list(~[list.isdir]);

   if opts.mfiles == true
      list = list(strncmp(reverse({list.name}), 'm.', 2));
   end

   if opts.aslist == true

      if opts.fullpath
         list = transpose(fullfile({list.folder}, {list.name}));
      else
         list = transpose(fullfile({list.name}));
      end

      % convert to string array if requested
      if opts.asstring == true
         list = string(list);
      end
   end
end
