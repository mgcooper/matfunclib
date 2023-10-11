function proplist = completions(funcname)
   %COMPLETIONS Generate function auto-completions for string literals.

   % Set the toolbox namespace.
   [~, pkgname] = mpackagename();

   switch lower(funcname)

      case 'completions'

         % To generate a completions list of all functions in +pkg folder:
         % tmp = dir(fullfile(toolboxpath(), pkgname, '*.m'));
         % proplist = strrep({tmp.name}, '.m', '');

         % To generate them dynamically from this switch-case block:
         proplist = strrep(getCases(), '''', '');
         
         % To hard-code them using all members of the case set below:
         %proplist = {'open', 'privatefunction', 'folders', 'subfolders', 'help'};

      case 'open'
         % restrict to +pkg files
         tmp = dir(fullfile(toolboxpath(), pkgname, '*.m'));
         proplist = strrep({tmp.name}, '.m', '')';

      case 'privatefunction'
         allfolders = listfolders(projectpath(), -1, 'fullpaths');
         allprivate = allfolders(contains(allfolders, 'private'));
         tmp = listfiles(allprivate, 'aslist', true, 'mfiles', true);
         proplist = erase(tmp, '.m');
         
         % tmp = dir(fullfile(toolboxpath(), pkgname, 'private', '*.m'));
         % proplist = strrep({tmp.name}, '.m', '')';

      case 'folders'
         % This only returns the top-level folders

         proplist = listfolders(projectpath());

      case 'subfolders'
         % This returns subfolders

         % Remove folders if any part of the path starts with a dot
         tmp = dir(fullfile(projectpath(), '**/*'));
         tmp = tmp([tmp.isdir]);
         drop = contains( ...
            {tmp.folder}, {'.git', 'resources'}) | strncmp({tmp.name}, '.', 1);
         tmp(drop) = [];
         proplist = {tmp.name}';

      case 'help'
         tmp = dir(fullfile(toolboxpath(), 'docs', '**/*.html'));
         proplist = strrep({tmp.name}, '.html', '')';
   end
