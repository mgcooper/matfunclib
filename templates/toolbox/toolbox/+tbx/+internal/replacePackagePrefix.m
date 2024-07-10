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

   if isoctave
      error([mfilename ' is not octave compatible'])
   end

   [pathname, old_prefix, new_prefix, dryrun] = parseinputs( ...
      pathname, old_prefix, new_prefix, varargin{:});

   % Create "pkg." and "+pkg" prefixes
   old_prefix_dot = [old_prefix '.'];
   new_prefix_dot = [new_prefix '.'];

   plus_old_prefix = ['+' old_prefix];
   plus_new_prefix = ['+' new_prefix];

   % Generate a list of all mfiles in the project
   mlist = dir(fullfile(pathname, '**/*.m'));
   jlist = dir(fullfile(pathname, '**/*.json'));

   list = [mlist; jlist];
   list(strncmp({list.name}, '.', 1)) = [];
   list(contains({list.folder}, 'sandbox')) = [];

   % OPEN ALL THE FILES AND REPLACE THE PREFIX

   for n = 1:numel(list)

      filename = fullfile(list(n).folder, list(n).name);
      fid = fopen(filename);

      % read in the function to a char
      wholefile = fscanf(fid, '%c');
      fclose(fid);

      % replace the prefix
      if contains(wholefile, old_prefix_dot)
         wholefile = strrep(wholefile, old_prefix_dot, new_prefix_dot);
      end

      if contains(wholefile, upper(plus_old_prefix))
         wholefile = strrep(wholefile, upper(plus_old_prefix), upper(plus_new_prefix));
      end

      if contains(wholefile, lower(plus_old_prefix))
         wholefile = strrep(wholefile, lower(plus_old_prefix), lower(plus_new_prefix));
      end

      % REWRITE THE FILE (DANGER ZONE)
      if dryrun == false
         fid = fopen(filename, 'wt');
         fprintf(fid, '%c', wholefile);
         fclose(fid);
      else
         disp(filename)
      end
   end
end

function [pathname, old_prefix, new_prefix, dryrun] = parseinputs( ...
      pathname, old_prefix, new_prefix, varargin)

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

   % If the old_prefix ends with a dot, remove it (it is appended later)
   if endsWith(old_prefix, '.')
      old_prefix = erase(old_prefix, '.');
   end
   if startsWith(old_prefix, '+')
      old_prefix = erase(old_prefix, '+');
   end

   % Repeat for the new prefix
   if endsWith(new_prefix, '.')
      new_prefix = erase(new_prefix, '.');
   end
   if startsWith(new_prefix, '+')
      new_prefix = erase(new_prefix, '+');
   end
end
