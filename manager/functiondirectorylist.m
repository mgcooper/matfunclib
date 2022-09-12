function list = functiondirectorylist

functionpath = getenv('MATLABFUNCTIONPATH');
list = dir(fullfile(functionpath));
list(strncmp({list.name}, '.', 1)) = []; 
list = string({list([list.isdir]).name}');