function rmproject(projectname, varargin)
   %RMPROJECT Remove project from project directory (does not delete folders).
   %
   %  RMPROJECT(PROJECTNAME) removes the row for the project with name
   %  projectname from the project directory list.
   %
   % Example
   %
   % rmproject('interface')
   %
   % After adding interface-e3sm and setting the activefiles using setprojectfiles
   % (see example there), I switched to interface-e3sm then removed the old
   % interface (which was linked to E3SM-Offline-Mode):
   %
   % Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
   %
   % See also: mkproject, workon, workoff

   % input parsing
   [projectname, keepsource] = parseinputs(mfilename, projectname, varargin{:});

   % main function
   projlist = readprjdirectory();
   projindx = getprjidx(projectname, projlist);

   disp(['removing ' projectname ' from project directory']);

   % check if the requested project is the activeproject
   wasactive = false;
   if any(projlist.activeproject(getprjidx(projectname)) == true)
      wasactive = true;
   end

   % Option to remove the project directory
   if ~keepsource

      if sum(projindx) > 0
         projectpath = fullfile(projlist.folder{projindx}, projectname);
      end

      assert(isfolder(projectpath), 'Project folder does not exist')

      msg = sprintf(['Moving project source folder to the trash: \n %s \n' ...
         'Press "y" to continue or any other key to abort.\n'], projectpath);
      str = input(msg, 's');

      if string(str) == "y"

         previousState = recycle("on");
         cleanupJob = onCleanup(@() recycle(previousState));

         [status, message, ~] = rmdir(projectpath, 's');

         if ~status
            disp(message)
         end

         % Using system:
         % status = system(['rm -r ' projectpath], "-echo");
         % if isfolder(projectpath)
         %    status = system(['rmdir ' projectpath], "-echo");
         % end
      end
   end

   % remove the project from the directory (does not delete the actual files)
   projlist(projindx,:) = [];

   % NOTE: below here, projindx no longer maps onto projlist

   if wasactive
      projlist.activeproject(1:end) = false;
      projlist.activeproject(ismember(projlist.name, 'default')) = true;
      setenv('MATLABACTIVEPROJECT', 'default');
   end

   % final step
   writeprjdirectory(projlist);
end

%% INPUT PARSER
function [projectname, keepsource] = parseinputs(funcname, projectname, varargin)

   parser = inputParser();
   parser.FunctionName = funcname;
   parser.addRequired('projectname', @isscalartext);
   parser.addParameter('keepsource', true, @islogicalscalar);
   parser.parse(projectname, varargin{:});

   projectname = parser.Results.projectname;
   keepsource = parser.Results.keepsource;
end
