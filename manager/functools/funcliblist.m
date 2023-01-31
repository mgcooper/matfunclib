function list = funcliblist
% modified this from functiondirectorylist to strip 'lib' so autocomplete is
% easier with mkfunction. update other functions that use it as they come up
% UPDATE but the library name is used to find the fullpath in mkfunction so i
% changed it back in the functionsig file for mkfunction. for now this is unused
functionpath = getenv('MATLABFUNCTIONPATH');
list = dir(fullfile(functionpath));
list(strncmp({list.name}, '.', 1)) = []; 
list = strrep(string({list([list.isdir]).name}'),'lib','');