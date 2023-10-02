function list = funcliblist()
   %FUNCLIBLIST 
   
   % I modified this from functiondirectorylist to strip 'lib' so autocomplete
   % is easier with mkfunction. If other functions use this they need to
   % re-append 'lib' if paths are built.
   % 
   % UPDATE but the library name is used to find the fullpath in mkfunction so i
   % changed it back in the functionSignatures file for mkfunction. 
   % 
   % Therefore this is unused for now. 
   
   functionpath = getenv('MATLABFUNCTIONPATH');
   list = dir(fullfile(functionpath));
   list(strncmp({list.name}, '.', 1)) = [];
   list = strrep(string({list([list.isdir]).name}'),'lib','');
end
