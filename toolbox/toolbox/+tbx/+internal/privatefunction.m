function F = privatefunction(funcName)
   % PRIVATEFUNCTION Return handle(s) to private functions in toolbox.
   %
   % F = privatefunction() returns a struct F containing function handles to all
   % private functions within the toolbox. Each field in the struct corresponds
   % to a 'private/' folder within the toolbox. The field value is another
   % struct with field names corresponding to function names and field values
   % being function handles.
   %
   % F = privatefunction(funcName) returns a function handle to the specified
   % function funcName, which is expected to be located within a 'private/'
   % folder in the toolbox. This function searches recursively in the toolbox
   % to find and return the appropriate function handle.
   %
   % This function uses completions.m to generate a list of available private
   % functions for tab-completion and input validation. It uses listfolders.m
   % and listfiles.m to find all 'private/' folders and .m files within the
   % toolbox.
   %
   % This function must be located in the toolbox's internal directory.
   %
   % See also: completions, listfolders, listfiles, projectpath

   % Validate input
   if nargin > 0 && ~ischar(convertStringsToChars(funcName))
      error('Invalid input. Expected a string or char for function name.');
   end

   cwd = pwd();
   job = onCleanup(@(~) cd(cwd));

   % Get a list of all private functions in the toolbox
   allfolderslist = listfolders(projectpath(), -1, 'fullpaths');
   allprivatefolders = allfolderslist(contains(allfolderslist, 'private'));

   % If called with no input, return a struct of function handles to all private
   % functions, organized by the parent folders.
   returnAllFunctions = false;
   if nargin < 1
      F = cell(numel(allprivatefolders), 1);
      returnAllFunctions = true;
   end

   for n = 1:numel(allprivatefolders)
      funcList = listfiles(allprivatefolders{n}, 'aslist', true, 'mfiles', true);
      funcList = erase(funcList, '.m');

      % cd to the private folder parent so the private function is in scope
      cd(allprivatefolders{n});
      
      if returnAllFunctions
         H = cellfun(@str2func, funcList, 'UniformOutput', 0);
         F{n} = cell2struct(H, cellfun(@func2str, H, 'UniformOutput', 0), 1);
      else
         if ismember(funcName, funcList)
            % H = cellfun(@str2func, funcList, 'UniformOutput', 0);
            % H = cellfun(@str2func, {funcName}, 'UniformOutput', 0);
            F = str2func(funcName);

            % use this to confirm correct scoping
            % functions(F)
            return
         end
      end
   end

   if isempty(F)
      if nargin == 1
         error('Function %s not found in any private directories.', funcName);
      elseif nargin == 0
         error('No functions found in any private directories.');
      end
   end

   % Convert to a function module (struct)
   if returnAllFunctions
      [~, privateFolders] = fileparts(fileparts(allprivatefolders));
      privateFolders = erase(privateFolders, {'+', '@'});
      F = cell2struct(F, privateFolders, 1);
   end
end
