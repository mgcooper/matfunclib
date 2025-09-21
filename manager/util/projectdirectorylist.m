function list = projectdirectorylist
   %PROJECTDIRECTORYLIST Return a list of project folders.
   %
   % Return a list of projects (folder names in MATLAB_PROJECT_PATH and
   % USER_PROJECT_PATH). currently used for json file autocomplete, see
   % buildprojectdirectory for building the directory.
   %
   % See also: buildprojectdirectory

   projectpath = getenv('MATLAB_PROJECT_PATH');
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

   % Jul 2024 - replace USER_PROJECT_PATH with MATLAB_PROJECT_PATH and stop using
   % USER_PROJECT_PATH for any matlab projects.
   projectpath = getenv('MATLAB_PROJECT_PATH');
   projectlist = mkprojectlist(projectpath);
   newlist     = [oldlist; projectlist];
end
