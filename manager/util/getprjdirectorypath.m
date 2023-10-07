function prjpath = getprjdirectorypath()
   prjpath = fullfile(getenv('PROJECTDIRECTORYPATH'),'projectdirectory.mat');
   % prjpath = fullfile(getenv('PROJECTDIRECTORYPATH'),'projectdirectory.csv');
end
