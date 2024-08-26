function result = toolboxUrlList(kwargs)

   arguments
      kwargs.verbose (1, 1) logical = false
   end

   % PICK UP NOTES:
   % what would get lost:
   % individual files like readme's I added to library folders or any folder
   % any custom and/or uncommitted changes
   % any sub repos I may have added I dont think there are any but maybe in
   % antarctic mapping tools I know I added a bunch of chad's folders
   % timescales is incorrectly labeled a library, maybe b/c of @folder
   %
   % Thus, todo:
   % - resolve any uncommitted changes
   % - determine which toolboxes have git repos and replace them
   % - determine which ones don't and it would be a problem to lose them
   % - backup a list of them all to later reconstruct if needed or if run out of
   % time

   toppath = gettbsourcepath();

   % sublist includes top-level folders and subfolders one level deep (levels
   % 0 and 1), meaning it captures toolboxes within library folders, but also
   % toolbox subfolders. The toolbox subfolders are removed after the loop b/c
   % those folders won't have .git repos.
   toplist = string(listfolders(toppath, 0, 'fullpath'));
   sublist = string(listfolders(toppath, 1, 'fullpath'));

   keep = true(size(sublist));

   % For reference, the only reason this alone is insufficient is b/c this does
   % not identify and remove the top-level toolbox subfolders. This can be
   % inferred by noticing that the only difference between the outer loop below
   % and the inner loop is the updating of "keep" to remove subfolders.
   % [remotes, messages] = arraymap(@processOneFolder, sublist);
   % keep = ~ismissing(remotes);

   % Check each folder for presence of .git and retrieve remote url.
   for n = numel(toplist):-1:1

      if isfolder(fullfile(toplist(n), '.git')) && keep(n)
         [url, msg] = processOneFolder(sublist(n));

         remotes(n, 1) = url;
         messages(n, 1) = msg;

         % Set subfolders of the toolbox to false.
         keep(ismember(sublist, ...
            string(listfolders(toplist(n), 0, 'fullpath')))) = false;
      else
         sublist_ = string(listfolders(toplist(n), 0, 'fullpath'));

         if isempty(sublist_)
            % This is a top-level toolbox with no .git and no subfolders
            continue
         else
            % Check if this is a library folder with toolboxes in subfolders
            [url_, msg_] = arraymap(@processOneFolder, sublist_);
            [url_, msg_] = deal(string(url_), string(msg_));

            if all(ismissing(url_))
               % See notes at end.
            else
               % This is a library folder with toolboxes with .git folders.
            end
            remotes(ismember(sublist, sublist_)) = url_;
            messages(ismember(sublist, sublist_)) = msg_;
            % No need to set subfolders false b/c sublist is only one level deep
         end
      end
   end
   sublist = sublist(keep);
   remotes = remotes(keep);
   messages = messages(keep);

   % Create the table.
   result = table(sublist, remotes, 'VariableNames', {'folder', 'remote'});

   % Remove the tbsourcepath from the folder path, and add a "library" variable.
   result.folder = erase(result.folder, toppath + "/");
   result.library = fileparts(result.folder);

   % Remove top-level library folders.
   drop = ismember(result.folder, unique(result.library));
   if any(~ismissing(result.remote(drop)))
      % a folder labeled library is under source control, something is wrong
   end
   result(drop, :) = [];

   % Sort the table alphabetically for visual comparison with the actual folder.
   [~, idx] = sort(lower(result.folder));
   result = result(idx, :);

   % If requested, display the messages
   if kwargs.verbose
      arrayfun(@(str) fprintf(1, str), messages)
   end
end

function [cmdout, msg] = processOneFolder(folderPath)

   dotGitPath = fullfile(folderPath, '.git');

   cmdout = string(nan);
   if isfolder(dotGitPath)

      msg = string(sprintf('Found .git in: %s\n', folderPath));

      % Retrieve the remote URL (if any)
      [status, cmdout] = system(sprintf( ...
         'git -C "%s" remote get-url origin', folderPath));

      cmdout = string(strtrim(cmdout));

      if status == 0
         % a remote URL was found
         msg = msg + sprintf('Remote URL: %s\n', cmdout);
      else
         msg = msg + sprintf('No remote URL found or failed to retrieve.\n');
      end
   else
      msg = string(sprintf('.git not found in: %s\n', folderPath));
   end
end

% This is a library folder with no subfolders which have .git, or
% a top-level toolbox with no .git, but with subfolders. If this
% is a library its no problem, the top-level library folder is
% removed after this loop along with all other library folders,
% and the subfolders are kept as intended. If this is a top-level
% toolbox with no .git but with subfolders, there's no way to
% distinguish it from a library without any .git subfolders. This
% is problematic b/c the toolbox subfolders should be dropped,
% but this did not occur so its no problem.
%
% For now, do nothing - this only occurs for libraries with no
% .git subfolders (e.g. "wind"). Doing nothing keeps them all
