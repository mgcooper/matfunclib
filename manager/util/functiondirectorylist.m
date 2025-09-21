function list = functiondirectorylist()
   functionpath = getenv('MATLAB_FUNCTION_PATH');
   list = dir(fullfile(functionpath));
   list(strncmp({list.name}, '.', 1)) = [];
   list = string({list([list.isdir]).name}');
end
