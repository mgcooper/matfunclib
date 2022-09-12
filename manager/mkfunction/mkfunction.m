function mkfunction(name,varargin)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'mkfunction';
   
   addRequired(p,'name',                  @(x)ischar(x)     );
   addParameter(p,'category', 'unsorted',    @(x)ischar(x)     );
   
   parse(p,name,varargin{:});
   
   funcname = p.Results.name;
   category = p.Results.category;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   functionpath   = [getenv('MATLABFUNCTIONPATH') category '/' funcname '/'];
   filenamepath   = [functionpath funcname '.m'];
   
   % first try adding the path in case it exists but isn't on path - if the
   % path doesn't exist, it won't issue an error (but addpath alone,
   % without genpath, will issue an error)
   addpath(genpath(functionpath));
   
   if exist(functionpath,'dir')
      
      % function already exists, append _tmp to copy files
      mkappendfunc(functionpath,funcname);
      
   else
      % function doesn't exist, make a new one
      system(sprintf('mkdir %s',functionpath));
      addpath(genpath(functionpath));
      
      mknewfunc(functionpath,filenamepath,funcname);
      
   end
   
end

function mkappendfunc(functionpath,funcname)
   
   filenamepath   = [functionpath funcname '_tmp.m'];
   
   msg = 'function folder exists, press ''y'' to copy function templates into directory as temporary files ';
   msg = [msg 'or any other key to return\n'];
   str = input(msg,'s');

   if string(str) == "y"
      mknewfunc(functionpath,filenamepath,funcname);
   else
      return;
   end
   
end

function mknewfunc(functionpath,filenamepath,funcname)
   
   % copy the template 
   copyfunctemplate(filenamepath);     % specify path w/file name
   copyjsontemplate(functionpath);     % specify path
   
   % replace 'myfunc' with the actual function name
   
   % not sure if there's any benefit to fileread vs fscanf
   % wholefile = fileread(filenamepath);
   fid         = fopen(filenamepath);
   wholefile   = fscanf(fid,'%c');     fclose(fid);
        
   wholefile   = strrep(wholefile,'myfunc',funcname);
   wholefile   = strrep(wholefile,'functemplate',funcname);
   
   % write it over again
   fid = fopen(filenamepath, 'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);
  
   % go to the new directory and open the new function file and json file
   cd(functionpath);
   edit(filenamepath);
   
   % if a signature file already exists, open it, otherwise edit the _tmp
   if exist([functionpath 'functionSignatures.json'],'file')
      edit('functionSignatures.json');
   end
   
   doc JSON Representation of MATLAB Data Types
   doc validateattributes
   
   
end
   