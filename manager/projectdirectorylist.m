function list = projectdirectorylist
   %PROJECTDIRECTORYLIST Return a list of project folders.
   % 
   % Return a list of projects (folder names in MATLABPROJECTPATH and
   % USERPROJECTPATH). currently used for json file autocomplete, see
   % buildprojectdirectory for building the directory. 
   %
   % See also: buildprojectdirectory

   projectpath = getenv('MATLABPROJECTPATH');
   list = mkprojectlist(projectpath);

   % Nov 30, 2022, migrated this from buildprojectdirectory so mkfunction and
   % other functions can use projectdirectorylist in choices={ statements
   list = appendprojectlist(list);
end

%% Local functions
function list = mkprojectlist(projectpath)

   list = rmdotfolders(dir(fullfile(projectpath)));
   list = string({list([list.isdir]).name}');
end

function newlist = appendprojectlist(oldlist)

   projectpath = getenv('USERPROJECTPATH');
   projectlist = mkprojectlist(projectpath);
   newlist     = [oldlist; projectlist];
end
