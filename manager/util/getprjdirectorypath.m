function prjpath = getprjdirectorypath()
   prjpath = fullfile(getenv('MATLAB_DIRECTORY_PATH'),'projectdirectory.mat');
   % prjpath = fullfile(getenv('MATLAB_DIRECTORY_PATH'),'projectdirectory.csv');
end
