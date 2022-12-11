function buildprojectdirectory
   
projectpath    = getenv('MATLABPROJECTPATH');
directorypath  = getenv('PROJECTDIRECTORYPATH');
projectlist    = getlist(projectpath,'*');
projectlist    = struct2table(projectlist);

% 23 Nov 2022 - also add projects in USERPROJECTPATH
projectlist    = appendprojects(projectlist);

% 23 Nov 2022 - remove entries that are not directories
projectlist    = projectlist(projectlist.isdir,:);

writetable(projectlist,[directorypath 'projectdirectory.csv']);
   
function newprojectlist = appendprojects(oldprojectlist)

projectpath    = getenv('USERPROJECTPATH');
projectlist    = getlist(projectpath,'*');
projectlist    = struct2table(projectlist);
newprojectlist = [oldprojectlist; projectlist];
      
   