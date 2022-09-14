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
   
   % this would be needed if i was appending it to the end of the table,
   % but with buildprojectdirectory method, we just reubild it every time,
   % in which case we need to get prjidx after adding it to send to tjhe
   % subfunctions
   %prjidx      = height(projects)+1;   
   
   if any(ismember(projects.name,projectname))
      
      error('project already in directory');
      
   else

      disp(['adding ' projectname ' to project directory']);
      buildprojectdirectory;
      
      % this is based on the tb method which is more complicated, that
      % directory only has two columns so i just add the name and path, but
      % buildprojectdirectory is better, it just uses the outupt of dir(),
      % so i just use buildprojectdirectory as above
      %projects(prjidx,:) = {projectname,prjpath};
      %writeprjdirectory(projects,dbpath);
   
   end
   
   projects = readprjdirectory(dbpath); % read the directory into memory
   prjidx   = find(ismember(projects.name,projectname));
   
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
   
   
   
   
   
   
   
   