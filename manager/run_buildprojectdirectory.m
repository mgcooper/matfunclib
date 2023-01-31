clean

% prebuild is a custom option to migrate the opened files and active project
% concept from projects.m to my project manager directory

prebuild = false;
dryrun = true;

fname = fullfile(getenv('PROJECTDIRECTORYPATH'),'projectdirectory.csv');

if prebuild == true

   % first migrate the 'projects.m' projectList active files to my projectlist
   cd(userpath);
   load('projects.mat');
   
   ProjectNames = {projectsList.ProjectName};
   
   % load my projectdirectory
   projectlist = readprjdirectory(getprjdirectorypath);
   projectlist.activefiles(1:size(projectlist,1)) = {''};
   projectlist.activeproject(1:size(projectlist,1)) = false;
   
   % add a 'default' project
   defaultproj = projectlist(end,:);
   defaultproj.name = {'default'};
   try
      defaultproj.folder = getenv('MATLABUSERPATH');
   catch
      defaultproj.folder = userpath;
   end
   projectlist = [projectlist; defaultproj];
   
   
   for m = 1:size(projectlist,1)
      if ismember(projectlist.name(m),ProjectNames)
         idx = ismember(ProjectNames,projectlist.name(m));
         projectlist.activefiles{m} = transpose(projectsList(idx).OpenedFiles);
      end
   end
   
   projectlist.activeproject(32) = true;
   
   % save the project directory
%    writetable(projectlist,fname);
   save(strrep(fname,'csv','mat'),'projectlist');

end

%% now try rebuilding

% projectlist = buildprojectdirectory('rebuild','dryrun');
projectlist = buildprojectdirectory('rebuild');





