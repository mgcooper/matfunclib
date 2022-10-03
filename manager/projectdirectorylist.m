function list = projectdirectorylist

projectpath = getenv('MATLABPROJECTPATH');
list = dir(fullfile(projectpath));
list(strncmp({list.name}, '.', 1)) = []; 
list = string({list([list.isdir]).name}');