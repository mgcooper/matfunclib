function projects = addproject(projectname,varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'addproject';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   addRequired(p,'projectname',@(x)ischar(x));
   addOptional(p,'workon','',@(x)ischar(x));

   parse(p,projectname,varargin{:});
   projectname = p.Results.projectname;
   workon      = p.Results.workon;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   dbpath      = getprjdirectorypath;      % tb database (directory) path
   prjpath     = getprjsourcepath(projectname); % tb source path
   projects    = readprjdirectory(dbpath); % read the directory into memory
   
   prjidx      = height(projects)+1;   
   
   if any(ismember(projects.name,projectname))
      
      error('project already in directory');
      
   else
   
      projects(prjidx,:)      = {projectname,prjpath};

      disp(['adding ' projectname ' to project directory']);

      writeprjdirectory(projects,dbpath);
   
   end
   
   % add it to the json directory choices for function 'activate'
   addtojsondirectory(projects,prjidx,'workon');
   
   % repeat for 'deactivate'
   addtojsondirectory(projects,prjidx,'workoff');
   
   % activate the toolbox if requested
   if string(workon)=="workon"
      workon(projectname);
   end
   
end

function addtojsondirectory(projects,prjidx,directoryname)
   
   jspath      = getprjjsonpath(directoryname);
   wholefile   = readprjjsonfile(jspath);
        
   % replace the most recent entry with itself + the new one
   prjfind     = sprintf('''%s''',projects.name{prjidx-1});
   prjreplace  = sprintf('%s,''%s''',prjfind,projects.name{prjidx});
   wholefile   = strrep(wholefile,prjfind,prjreplace);
   
   % write it over again
   writeprjjsonfile(jspath,wholefile)

end
   
   
   
   
   
   
   
   