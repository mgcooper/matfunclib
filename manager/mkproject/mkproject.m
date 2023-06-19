function mkproject(projectname,varargin)
%MKPROJECT general description of function
%
%  msg = MKPROJECT(cmd) description
%  msg = MKPROJECT(cmd,'name1',value1) description
%  msg = MKPROJECT(cmd,'name1',value1,'name2',value2) description
%  msg = MKPROJECT(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'.
%
% Example
%
%
% Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
%
% See also

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p = inputParser;
p.FunctionName = mfilename;

validoptions = @(x)~isempty(validatestring(x,{'workon'})) | isempty(x);

addRequired(p,'projectname',@(x)ischar(x));
addOptional(p,'workon','',validoptions);
addParameter(p,'setfiles',false,@(x)islogical(x));
addParameter(p,'setactive',false,@(x)islogical(x));

parse(p,projectname,varargin{:});

projectname = p.Results.projectname;
workon = p.Results.workon;
setfiles = p.Results.setfiles;
setactive = p.Results.setactive;

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%-------------------------------------------------------------------------------


projectpath = fullfile(getenv('MATLABPROJECTPATH'),projectname);

if isfolder(projectpath)

   msg = sprintf(['\nproject already exists in %s,\n' ...
      'press ''y'' to add the existing project or any other key to exit\n'],projectpath);
   str = input(msg,'s');
   
   if string(str) == "y"
      % add the existing project to the project directory
      addproject(projectname,workon);
   else
      return
   end
else
   if isfolder(fileparts(projectpath))
      mkdir(projectpath)
   else
      error('project path parent folder does not exist: %s',fileparts(projectpath));
   end

   % add the new project to the project directory
   addproject(projectname,workon);
end

% post mk options
if setfiles
   setprojectfiles(projectname);
end

if setactive
   setprojectactive(projectname)
end












