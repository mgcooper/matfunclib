function buildprojectdirectory
   
   projectpath    = getenv('MATLABPROJECTPATH');
   directorypath  = getenv('PROJECTDIRECTORYPATH');
   projectlist    = getlist(projectpath,'*');
   projectlist    = struct2table(projectlist);
   
   writetable(projectlist,[directorypath 'projectdirectory.csv']);
      
   