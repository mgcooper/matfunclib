function msg = copytoolboxtemplate(projectname, opts)
%COPYTOOLBOXTEMPLATE copy toolbox template to MATLABPROJECTPATH/projectname
%
%
% See also

arguments
   projectname (1, :) char
   opts.forcecopy (1, 1) logical = false
   opts.safecopy (1, 1) logical = false
end

% Build the full path to the toolbox template
tbxtemplate = fullfile(getenv('MATLABTEMPLATEPATH'), 'toolbox');

% Determine if PROJECTNAME 1) is a fullpath, 2) points to an existing project
% folder, and 3) is an existing project. If not, make the folder and copy the
% toolbox template there.

% Assumptions
isExistingProject = false;
isValidProjectPath = false;

if isempty(fileparts(projectname))
   % PROJECTNAME is a char, build the full path
   tbxpath = fullfile(getenv('MATLABPROJECTPATH'), projectname);
   
   % Copy the toolbox template, after one more check
   if ~isfolder(tbxpath)
      copyfile(tbxtemplate, tbxpath)
   end
else

   % Check if tbxname is a valid project folder 
   isValidProjectPath = strcmp(fileparts(projectname), getenv('MATLABPROJECTPATH'));
   
   % Check if tbxname is an existing project folder 
   isExistingProject = isValidProjectPath && isfolder(projectname);

   if isValidProjectPath || isExistingProject
      tbxpath = projectname;
      [~, tbxname] = fileparts(tbxpath);
   end
   
   % If its an existing project, this is likely a mistake
   if isExistingProject
      
      % Use this to investigate further.
      % [isInDirectory, hasProjectFolder] = isproject(tbxname);
      
      if numel(rmdotfolders(dir(tbxpath))) == 0 || opts.forcecopy == true
         % Copy the toolbox template into the (empty) project folder
         copyfile(tbxtemplate, tbxpath)
         
      elseif opts.safecopy == true
         % Copy the toolbox template into a temp folder
         copyfile(tbxtemplate, tempfile(tbxpath))
      else
         % Return an error
         error('project exists and is not empty, not copying toolbox template')
      end

   elseif isValidProjectPath
      % This means the path is valid but does not exist
      
      % create the project by copying the toolbox template to the folder
      copyfile(tbxtemplate, tbxpath)
   end
end

msg.isValidProjectPath = isValidProjectPath;
msg.isExistingProject = isExistingProject;

% % Not implemented, but an idea - either copy the template, or do nothing
% function copyOnCleanup(docopy, tbxtemplate, tbxpath)
% 
% ifelse(docopy, copyfile(tbxtemplate, tbxpath), [])
