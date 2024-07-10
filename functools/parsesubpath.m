function [subpath, found] = parsesubpath(basepath, valid_subfolder_names, ...
      default_subfolder_name, make_default_subfolder)
   %PARSESUBPATH Parse and validate a subfolder path relative to a base path
   %
   %   [subpath, found] = PARSESUBPATH(basepath, valid_subfolder_names, ...
   %                      default_subfolder_name, make_default_subfolder)
   %
   %   Inputs:
   %       basepath               - Base path where subfolders will be checked.
   %       valid_subfolder_names  - Cell array of valid subfolder names to check
   %                                under basepath.
   %       default_subfolder_name - Name of the default subfolder to use if none
   %                                of the valid subfolders are found.
   %       make_default_subfolder - Optional flag indicating whether to create
   %                                default_subfolder_name if it doesn't exist.
   %                                Default is false.
   %
   %   Outputs:
   %       subpath - Validated subfolder path found relative to basepath.
   %       found   - Logical indicating if subpath was found (true) or not (false).
   %
   %   Description:
   %       PARSESUBPATH searches for the existence of subfolders specified in
   %       valid_subfolder_names under basepath. If multiple valid subfolders
   %       are found, it returns the first match. If none are found, it either
   %       creates the default_subfolder_name (if make_default_subfolder is
   %       true) or returns an empty subpath with a warning. The function checks
   %       the existence of each subfolder using isfolder().
   %
   %   Example:
   %       base = '/path/to/base/';
   %       valid_folders = {'data', 'results', 'backup'};
   %       default_folder = 'data';
   %       [subfolder, found] = parsesubpath(base, valid_folders, default_folder);
   %
   %       if found
   %           disp(['Found subfolder: ' subfolder]);
   %       else
   %           disp('No valid subfolder found or created.');
   %       end
   %
   % See also: ISFOLDER, MKDIR, FULLFILE

   % Validate input arguments
   if nargin < 4
      make_default_subfolder = false;
   end

   % Construct full paths to valid subfolders
   possible_subpaths = fullfile(basepath, valid_subfolder_names);

   % Check existence of each subfolder
   subpath = possible_subpaths(isfolder(possible_subpaths));

   % Handle cases based on the results
   if isempty(subpath)
      % No valid subfolder found, use default
      subpath = fullfile(basepath, default_subfolder_name);

      if make_default_subfolder
         % Optionally create default subfolder if it doesn't exist
         warning('%s directory not found. Making it now.', ...
            default_subfolder_name)
         mkdir(subpath)
      else
         % Warn user and return an empty subpath
         warning('%s directory not found. Returning an empty subpath.', ...
            default_subfolder_name)
      end

   else
      % Multiple matches found, return the first one
      if numel(subpath) > 1
         warning(['More than one match found in valid_subfolder_names. ' ...
            'Returning the first match found.'])
      end
      subpath = subpath{1};
   end

   % Check if a valid subpath was found
   found = isfolder(subpath);
end
