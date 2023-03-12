function varargout = buildprojectdirectory(varargin)
%BUILDPROJECTDIRECTORY build project directory file
% 
%  projectlist = buildprojectdirectory('dryrun') builds a projectlist directory
%  that would be saved in the `PROJECTDIRECTORYPATH` folder but does not save
%  it. Use this to build the project directory from scratch using the folders in
%  the directory set by the MATLABPROJECTPATH environment variable. If a
%  USERPROJECTPATH environemnt variable exists, folders in that directory will
%  also be added to the project list. Internal note: the .csv file is not used,
%  modified, saved, deleted, in any way. 
% 
%  buildprojectdirectory without any input or output arguments builds a project
%  directory file named `projectdirectory.mat` and saves it in the
%  `PROJECTDIRECTORYPATH` folder
% 
%  projectlist = buildprojectdirectory returns the project list saved in
%  projectdirectory.mat
% 
%  projectlist = buildprojectdirectory('rebuild') rebuilds the project directory
%  from scratch, retaining the `activefiles` property of the current directory
%  for projects that exist in the existing and rebuilt directory.
% 
% See also: workon, workoff, addproject, manager
% 
% Updates
% 19 Jan 2023 - appended projname to projectlist.activefolder and renamed
% projectlist.folder to projectlist.parentfolder
% 19 Jan 2023 - added 'activefolder' attribute to allow projects associated
% with folders other than their namesake
% 23 Nov 2022 - add projects in USERPROJECTPATH using appendprojects
% 23 Nov 2022 - remove entries that are not directories

% parse inputs
%-------------------------------------------------------------------------------
switch nargin
   case 1
      % the first option is either 'rebuild' or 'dryrun'
      validatestring(varargin{1},{'rebuild','dryrun'},mfilename,'option',1);
   case 2
      % if the first option is 'rebuild', the second option can be 'dryrun'.
      validatestring(varargin{2},{'dryrun'},mfilename,'option',2);
end
% this sets the options to true or false
opts = optionParser({'rebuild','dryrun'},varargin(:));

% warn if no rebuild or dryrun options are passed in
if nargin == 0
   opts = buildwarning(opts);
end
%-------------------------------------------------------------------------------

fname = fullfile(getenv('PROJECTDIRECTORYPATH'),'projectdirectory.mat');

% build the project list (if opts.rebuild is true, the rebuild option is used)
projectlist = buildprojectlist(opts);

% save the project directory
if opts.dryrun == false
   save(fname,'projectlist');
end

% package output
if nargout == 1
   varargout{1} = projectlist;
end


%-------------------------------------------------------------------------------
function opts = buildwarning(opts)
msg1 = 'Building project directory.';
msg2 = 'Warning: this will overwrite the existing directory if it exists.';
msg3 = 'Use option ''rebuild'' to rebuild the project directory and preserve existing directory attributes.';
msg4 = 'Press ''y'' to continue saving the new directory, or any other key to abort.';
msg = [newline msg1 newline msg2 newline msg3 newline msg4 newline];

commandwindow;
str = input(msg,'s');

if string(str) == "y"
   opts.dryrun = false;
else
   opts.dryrun = true;
end


%-------------------------------------------------------------------------------
function projectlist = buildprojectlist(opts)

projectpath = getenv('MATLABPROJECTPATH');
projectlist = getlist(projectpath,'*');
projectlist = struct2table(projectlist);
projectlist = appendprojects(projectlist); % 23 Nov 2022
projectlist = projectlist(projectlist.isdir,:); % 23 Nov 2022

% Decided to hold off on this b/c the catting of folder and name may be
% scattered throughout other functions. Could add a 'projectfolder' attribute.
% rename 'folder' to 'parentfolder'
% projectlist = renamevars(projectlist,'folder','parentfolder');

% add a 'default' project
defaultproj = projectlist(end,:);
defaultproj.name = {'default'};
try
   defaultproj.folder = getenv('MATLABUSERPATH');
catch
   defaultproj.folder = userpath;
end
projectlist = [projectlist; defaultproj];

% add empty custom attributes 'activefiles', 'activeproject', 'activefolder',
% and 'linkedproject' (the others are created by dir() )
projectlist.activefiles(1:size(projectlist,1)) = {''};
projectlist.activeproject(1:size(projectlist,1)) = false;
projectlist.activefolder = fullfile(projectlist.folder,projectlist.name);
projectlist.linkedproject(1:size(projectlist,1)) = {''};

% IF FIRST TIME WE'RE DONE HERE SO FOR DRYRUN OR DEBUGGING CHECK PROJECTLSIT

% this option preserves the custom attributes mentioned above
if opts.rebuild == true
   projectlist = rebuildprojectlist(projectlist);
end

%-------------------------------------------------------------------------------
function projectlist = appendprojects(oldprojectlist)

projectpath = getenv('USERPROJECTPATH');
if ~isempty(projectpath)
   projectlist = getlist(projectpath,'*');
   projectlist = struct2table(projectlist);
   projectlist = [oldprojectlist; projectlist];
else
   projectlist = oldprojectlist;
end


%-------------------------------------------------------------------------------
function projectlist = rebuildprojectlist(projectlist)

% read the current project directory
oldlist = readprjdirectory(getprjdirectorypath);

% find projects in both the old and new directories
keepatts = {'activefiles','activeproject','activefolder','linkedproject'};
for n = 1:numel(keepatts)
   
   thisatt = keepatts{n};

   for m = 1:size(projectlist,1)

      if ismember(projectlist.name(m),oldlist.name)
         idx = ismember(oldlist.name,projectlist.name(m));
         projectlist.(thisatt)(m) = oldlist.(thisatt)(idx);
      end

   end
end

