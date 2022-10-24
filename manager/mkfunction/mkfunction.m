function mkfunction(name,varargin)

%------------------------------------------------------------------------------
   p              = inputParser;
   p.FunctionName = 'mkfunction';
   
   addRequired(   p,'funcname',              @(x)ischar(x)  );
   addParameter(  p,'library',   'unsorted', @(x)ischar(x)  );
   addParameter(  p,'project',   'unsorted', @(x)ischar(x)  );
   addParameter(  p,'parser',    'MIP',      @(x)ischar(x)  );
   
%    % now that i understand addOptional, this may work:
%    validlib    = @(x)any(validatestring(x,functiondirectorylist));
%    validproj   = @(x)any(validatestring(x,projectdirectorylist));
%    validparser = @(x)any(validatestring(x,{'MIP','IP','ArgList'}));
%    
%    addRequired(   p,'funcname',              @(x)ischar(x)  );
%    addOptional(   p,'library',   'unsorted', validlib       );
%    addOptional(   p,'project',   'unsorted', validproj      );
%    addOptional(   p,'parser',    'MIP',      validparser    );
   
   % i think inputs and outputs will need to be structures to distinguish
   % required, parameter, optional, etc. but don't have time to sort it out rn
   %addParameter(  p,'inputs',    {'x'},      @(x)iscell(x)  );
   %addParameter(  p,'outputs',   {'x'},      @(x)iscell(x)  );
   
   parse(p,name,varargin{:});
   
   funcname = p.Results.funcname;
   library  = p.Results.library;
   project  = p.Results.project;
   parser   = p.Results.parser;
   %inputs   = p.Results.inputs;
   %outputs  = p.Results.outputs;

%------------------------------------------------------------------------------

   % get the function directory path and full path to new function filename
   [functionpath,filenamepath] = parseFunctionPath(funcname,library,project);
   
   % first try adding the path in case it exists but isn't on path - if the
   % path doesn't exist, it won't issue an error (but addpath alone, without
   % genpath, will issue an error)
   addpath(genpath(functionpath));
   
   if exist(functionpath,'dir')
      
      % function already exists, append _tmp to copy files
      mkappendfunc(functionpath,funcname,parser);
      %mkappendfunc(functionpath,funcname,parser,inputs,outputs);
      
   else
      % function doesn't exist, make a new one
      system(sprintf('mkdir %s',functionpath));
      addpath(genpath(functionpath));
      
      mknewfunc(functionpath,filenamepath,funcname,parser);
      %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
   end
   
end

function [functionpath,filenamepath] = parseFunctionPath(funcname,library,project)
      
% parse the function path. if library and project are both default
% "unsorted", OR if project is default "unsorted", use default function
% library. this gets both, and checks whether the function folder in the
% project dirs is 'func/' or 'functions/'

   if project == "unsorted"
      
      functionpath = [getenv('MATLABFUNCTIONPATH') library '/' funcname '/'];
      
   elseif project ~= "unsorted" && library == "unsorted"
      
      projectpath = [getenv('MATLABPROJECTPATH') project];
      
      % this makes 'func/' the default which will get created if requested
      if isfolder([projectpath '/functions/'])
         
         functionpath = [projectpath '/functions/' funcname '/'];
         
      elseif isfolder([projectpath '/func/'])
         
         functionpath = [projectpath '/func/' funcname '/'];
         
      else
         
         functionpath = [projectpath '/' funcname '/'];
         
      end
   end
   
   filenamepath   = [functionpath funcname '.m'];
end


function mkappendfunc(functionpath,funcname,parser)
   %mkappendfunc(functionpath,funcname,parser,inputs,outputs)
   
   filenamepath   = [functionpath funcname '_tmp.m'];
   
   msg = 'function folder exists, press ''y'' to copy function templates into directory as temporary files ';
   msg = [msg 'or any other key to return\n'];
   str = input(msg,'s');

   if string(str) == "y"
      mknewfunc(functionpath,filenamepath,funcname,parser);
      %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
   else
      return;
   end
   
end

function mknewfunc(functionpath,filenamepath,funcname,parser)
%function mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs)
   
   % copy the template 
   copyfunctemplate(filenamepath,parser);    % specify path w/file name
   copyjsontemplate(functionpath);           % specify path
   
   % replace 'funcname' with the actual function name in the function file
   
   % not sure if there's any benefit to fileread vs fscanf
   % wholefile = fileread(filenamepath);
   fid         = fopen(filenamepath);
   wholefile   = fscanf(fid,'%c');     fclose(fid);
        
   wholefile   = strrep(wholefile,'FUNCNAME',upper(funcname));
   wholefile   = strrep(wholefile,'funcname',funcname);
   wholefile   = strrep(wholefile,'functemplate',funcname);

% % need a way to read the entire line, replace 'x' with the input, and write it   
%    % add the function inputs
%    requiredinputfind = 'x';
%    for n = 1:numel(inputs)
%       requiredinputrepl = inputs{n};
%       wholefile = '';
%    end
   
   % write it over again
   fid = fopen(filenamepath, 'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);
  
   
   % repeat for functionSignature file
   fid         = fopen([functionpath 'functionSignatures.json']);
   wholefile   = fscanf(fid,'%c');     fclose(fid);     
   wholefile   = strrep(wholefile,'funcname',funcname);
   fid         = fopen([functionpath 'functionSignatures.json'], 'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);
   
   % go to the new directory and open the new function file and json file
   cd(functionpath);
   edit(filenamepath);
   
   % if a signature file already exists, open it, otherwise edit the _tmp
   if exist([functionpath 'functionSignatures.json'],'file') == 2
      edit('functionSignatures.json');
   end
   % NOTE: with new functionality of copyjsontemplate, it will check for an
   % existing one and if not, it will copy the template as
   % functionSignatures.json, so above check swhould always open it
   
   doc JSON Representation of MATLAB Data Types
   doc validateattributes
   
   
end
   