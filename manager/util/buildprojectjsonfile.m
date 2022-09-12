function buildprojectjsonfile
   
   % note: need to modify this to build the toolbox json from scratch
   
   % this requires a template is ready with a particular format:
   directorypath  = getenv('PROJECTDIRECTORYPATH');
   jsfile         = [directorypath 'functionSignatures.projecttemplate.json'];
   
   % getprjdirectorypath returns the path to the directory file:
   directorypath  = getprjdirectorypath;
   
   % read in the projects and create a character list to add to the json
   projects       = readprjdirectory(directorypath);
   list           = buildprojectjsonlist(projects);
   
   % read in the json template and add the project list
   fid         = fopen(jsfile);
   wholefile   = fscanf(fid,'%c');     fclose(fid);
        
   % replace the most recent entry with itself + the new one
   wholefile   = strrep(wholefile,'choices={}',list);
   
   % write it over again, this time to the 'workon' folder
   jspath      = getprjjsonpath('workon');
   writeprjjsonfile(jspath,wholefile)
   
   
end
   
function list = buildprojectjsonlist(projects)
   
   list = 'choices={''';

   for n = 1:numel(projects.name)
      if n == 1
         list = [list projects.name{n} ''','];
      elseif n == numel(projects.name)
         list = [list '''' projects.name{n} '''}'];
      else
         list = [list '''' projects.name{n} ''','];
      end
   end
end