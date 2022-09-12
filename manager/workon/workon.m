function workon(projectname,varargin)
%WORKON adds project 'projectname' to path and makes it the working directory
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'workon';
   
   addRequired(   p,'projectname',       @(x)ischar(x));
   addOptional(   p,'goto',   'goto', @(x)ischar(x));
   
   parse(p,projectname,varargin{:});
   
   projectname = p.Results.projectname;
   goto        = string(p.Results.goto) == "goto"; % transform to logical

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   dbpath      = getprjdirectorypath;
   projects    = readprjdirectory(dbpath);
   prjidx      = findprjentry(projects,projectname);

   if sum(prjidx) == 0
      msg = 'project not found in directory, press ''y'' to add it ';
      msg = [msg 'or any other key to return\n'];
      str = input(msg,'s');
      
      if string(str) == "y"
         addproject(projectname);
      else
         return;
      end
      
   end

   prjpath = getprjsourcepath(projectname);
   
   disp(['activating ' projectname]);
   addpath(genpath(prjpath));
   
   if goto; cd(prjpath); end   % cd to the activated tb if requested
   
   % remove .git files from path
   if contains(genpath([prjpath '*.git']),'.git')
      warning off; rmpath(genpath([prjpath '*.git'])); warning on; 
   end