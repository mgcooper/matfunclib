function replacePackagePrefix(pathname, old_prefix, new_prefix, varargin)
   %REPLACEPACKAGEPREFIX Replace namespace package prefix in function files.
   %
   %  REPLACEPACKAGEPREFIX(PATHNAME, OLD_PREFIX, NEW_PREFIX, DRYRUN)
   %
   % Description:
   %
   %  replacePackagePrefix(projectpath, old_prefix, new_prefix, true) Replaces
   %  all instances of OLD_PREFIX with NEW_PREFIX in all m-files in PROJECTPATH
   %  and all subdirectories.
   %
   %  replacePackagePrefix(projectpath, old_prefix, new_prefix, false) Performs
   %  a dry run.
   %
   % See also:

   narginchk(3, 4)
   if nargin < 4
      dryrun = true;
   end

   if isoctave
      error([mfilename ' is not octave compatible'])
   end

   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.addRequired('pathname', @isscalartext)
   parser.addRequired('old_prefix', @isscalartext)
   parser.addRequired('new_prefix', @isscalartext)
   parser.addOptional('dryrun', true, @islogicalscalar)
   parser.parse(pathname, old_prefix, new_prefix, varargin{:})
   dryrun = parser.Results.dryrun;

   [pathname, old_prefix, new_prefix] = convertStringsToChars( ...
      pathname, old_prefix, new_prefix);

   % Confirm that the last character of the old/new prefix is a dot
   if ~endsWith(old_prefix, '.')
      old_prefix = [old_prefix '.'];
   end
   if ~endsWith(new_prefix, '.')
      new_prefix = [new_prefix '.'];
   end

   % Generate a list of all mfiles in the project
   list = dir(fullfile(pathname, '**/*.m'));
   list(strncmp({list.name}, '.', 1)) = [];
   list(contains({list.folder}, 'sandbox')) = [];

   % OPEN ALL THE FILES AND REPLACE THE PREFIX

   for n = 1:numel(list)

      filename = fullfile(list(n).folder, list(n).name);
      fid = fopen(filename);

      % read in the function to a char
      wholefile = fscanf(fid, '%c'); fclose(fid);

      % replace the prefix
      if contains(wholefile, old_prefix)

         wholefile = strrep(wholefile, old_prefix, new_prefix);

         % REWRITE THE FILE (DANGER ZONE)
         if dryrun == false
            fid = fopen(filename, 'wt');
            fprintf(fid, '%c', wholefile); fclose(fid);
         else
            disp(filename)
         end
      end
   end
end
