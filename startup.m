% Matlab startup configuration

%% manage warnings

% Save the current state of the warnings
originalWarningState = warning;

% Create a cleanup object that will be executed when the function is exited
cleanupObj = onCleanup(@() warning(originalWarningState));

% Suppress warnings (e.g., generated by activating mpm)
warning("off", "MATLAB:dispatcher:nameConflict")
warning("off", "MATLAB:rmpath:DirNotFound");

%% custom settings

mSettings = settings;

% Prevent autoformatter from stripping blanks to prevent the cursor from being
% forced to the first position in indented code blocks (introduced in r2021b)
if ~verLessThan('matlab','9.11')
   mSettings.matlab.editor.indent.RemoveAutomaticWhitespace.PersonalValue = 0;
end

% Make the desktop display larger.
% mSettings.matlab.desktop.DisplayScaleFactor.TemporaryValue = 1.2;

% smartIndentContents (method of class Document) programmatically formats
% docs = matlab.desktop.editor.getAll
% smartIndentContents(docs)
% save(docs)

%% set paths

HOMEPATH = getenv('HOME'); % system $HOME

% This path can change, but changing MATLABUSERPATH will break many functions.
% Unfortunately, I should have used MATLABHOMEPATH for this variable, and
% MATLABUSERPATH should point to the same path returned by 'userpath'.
setenv('MATLABUSERPATH',fullfile(HOMEPATH,'MATLAB'));

% I set this to make the setenv statements syntax more compact:
MATLABPATH = getenv('MATLABUSERPATH');      % matlab home

% user project path
setenv('USERPROJECTPATH',fullfile(HOMEPATH,'myprojects'));

% matlab functions
setenv('MATLABFUNCTIONPATH',fullfile(MATLABPATH,'matfunclib'));
setenv('MATLABTEMPLATEPATH',fullfile(MATLABPATH,'matfunclib/templates'));

% manager
setenv('TBDIRECTORYPATH',fullfile(MATLABPATH,'directory'));
setenv('PROJECTDIRECTORYPATH',fullfile(MATLABPATH,'directory'));
setenv('TBJSONACTIVATEPATH',fullfile(MATLABPATH,'matfunclib/manager/activate'));
setenv('TBJSONDEACTIVATEPATH',fullfile(MATLABPATH,'matfunclib/manager/deactivate'));
setenv('PRJJSONWORKONPATH',fullfile(MATLABPATH,'matfunclib/manager/workon'));
setenv('PRJJSONWORKOFFPATH',fullfile(MATLABPATH,'matfunclib/manager/workoff'));

% file exchange
setenv('FEXFUNCTIONPATH',fullfile(MATLABPATH,'fexfunclib'));
setenv('FEXPACKAGEPATH',fullfile(MATLABPATH,'fexpackages'));

% user data
setenv('USERDATAPATH',fullfile(HOMEPATH,'work/data'));
setenv('USERGISPATH',fullfile(HOMEPATH,'work/data/interface/GIS_data'));

% project and source code
setenv('MATLABPROJECTPATH',fullfile(HOMEPATH,'myprojects/matlab'));
setenv('MATLABSOURCEPATH',fullfile(HOMEPATH,'mysource/matlab'));

% e3sm
setenv('E3SMINPUTPATH',fullfile(getenv('USERDATAPATH'),'e3sm/input'));
setenv('E3SMOUTPUTPATH',fullfile(getenv('USERDATAPATH'),'e3sm/output'));
setenv('E3SMTEMPLATEPATH',fullfile(getenv('USERDATAPATH'),'e3sm/templates'));

%% Add shared library to path

% Ignored folders - append these to ignorePaths to use
% ignore = {'old_projects'; 'myProjects'};

% Generate a list of all sub-folders
subpaths = strsplit(genpath(getenv('MATLABUSERPATH')), pathsep);

% Remove ignored folders
ignorePaths = {'.git'; '.svn'; '.'; '..'; };
keep = @(folders, ignore) cellfun('isempty', (strfind(folders, ignore)));

for m = 1:numel(ignorePaths)
   subpaths = subpaths(keep(subpaths, ignorePaths{m}));
end

% Rebuild the path string
subpaths = strcat(subpaths, pathsep);
subpaths = horzcat(subpaths{:});
   
% Add the paths to the path
addpath(subpaths);

%% Figure defaults
set(groot                                                   , ...
    'defaultAxesFontName'       ,   'SF Pro Text'           , ...
    'defaultTextFontName'       ,   'SF Pro Text'           , ...
    'defaultTextInterpreter'    ,   'Latex'                 , ...
    'defaultAxesFontSize'       ,   16                      , ...
    'defaultTextFontSize'       ,   16                      , ...
    'defaultLineLineWidth'      ,   2                       , ...
    'defaultAxesLineWidth'      ,   1                       , ...
    'defaultPatchLineWidth'     ,   1                       , ...
    'defaultAxesColor'          ,   'w'                     , ...
    'defaultFigureColor'        ,   'w'                     , ...
    'defaultAxesBox'            ,   'off'                   , ...
    'DefaultAxesTickLength'     ,   [0.015 0.02]            , ...
    'defaultAxesTickDir'        ,   'out'                   , ...
    'defaultAxesXGrid'          ,   'on'                    , ...
    'defaultAxesYGrid'          ,   'on'                    , ...
    'defaultAxesXMinorGrid'     ,   'off'                   , ...
    'defaultAxesXMinorTick'     ,   'on'                   , ...
    'defaultAxesYMinorGrid'     ,   'off'                   , ...
    'defaultAxesYMinorTick'     ,   'on'                   , ...
    'defaultAxesTickDirMode'    ,   'manual'                , ...
    'defaultAxesXMinorGridMode' ,   'manual'                , ...
    'defaultAxesXMinorTickMode' ,   'manual'                , ...
    'defaultAxesYMinorGridMode' ,   'manual'                , ...
    'defaultAxesYMinorTickMode' ,   'manual'                , ...
    'defaultAxesMinorGridLineStyle','-'                     , ...
    'defaultAxesMinorGridAlpha'    ,   0.075 );

%% Environment configuration 

% turn off the annoying error beep
beep off

% set format for numbers printed to screen so they're readable:
format shortG % try 'doc format' for examples
format compact % use pi to see different formats: pi

%% Python configuration

if verLessThan('matlab','9.11') % <r2021b use 3.8

   % dont think I want to use system python
   % pyenv('Version','/usr/bin/python3');

   % these both point to the first one, but not sure if the pyenv 'tools385'
   % one will also use the installed environment packages
   pyenv('Version',fullfile(HOMEPATH,'.pyenv/versions/3.8.5/bin/python'));
   % pyenv('Version',fullfile(HOMEPATH,'.pyenv/versions/tools385/bin/python'));
else
   pyenv('Version',fullfile(HOMEPATH,'.pyenv/versions/3.9.0/bin/python'));
   % pyenv('Version',fullfile(HOMEPATH,'.pyenv/versions/tools3/bin/python'));
end

%% copy this file to myFunctions where it lives under source control

% % 18 June 2023 - commented this out. I think I added this assuming that edits
% to this file would be made on the one in the startup folder, so this would
% copy it to matfunclib where it gets committed to source control, but 'open
% startup' opens the matfunclib one, so this is more likely to do the opposite -
% erase updates in that version before committing them. Keeping it for now in
% case I can update my path so 'open startup' always opens the startup folder
% version.

% startupFileNameSource = fullfile(userpath,'startup.m');
% startupFileNameDest = fullfile(getenv('MATLABFUNCTIONPATH'),'startup.m');
% copyfile(startupFileNameSource,startupFileNameDest);

%% activate toolboxes and projects

% active toolboxes
activate magicParser
activate BrewerMap
activate CubeHelix
activate mpm
activate CDT
activate antarctic-mapping-tools
activate arctic-mapping-tools
activate gridbin
% activate lightspeed

% open the active project
if usejava('desktop')
   workon(getactiveproject())
end

%% FINAL STEPS

% clear vars but not the screen b/c it deletes error msgs
clearvars

% don't forget
disp('BE GRATEFUL')

%% Notes

% % additional options I found I wasn't aware of:
% set(groot, ...
% 'DefaultAxesXColor', 'k', ...
% 'DefaultAxesYColor', 'k', ...
% 'DefaultAxesFontUnits', 'points', ...
% 'DefaultTextFontUnits', 'Points', ...

% default font is Monospaced but other good ones include:
% fontName = 'Verdana';
% fontName = 'avantgarde';
% fontName = 'BitstreamSansVeraMono';
% fontName = 'Helvetica';
% fontName = 'Source Sans Pro' (nice and compact also if bold)

% note: axes box off does not work because groot applies to low level
% properties, 'plot' is a high level function that puts on the box. setting
% defaultAxesBox off above means that 'line' will not produce a box

% use python 3
%pyenv('Version','/usr/bin/python3')
%pyenv('Version','/Users/coop558/.pyenv/shims/python3.8')

% regarding PATH, when matlab is started from command terminal, it inherits
% the PATH variable (modified in .bashrc), but when started from the gui
% icon, it inherits the 'default system PATH', which isn't the same as the
% one modified in .bashrc. 

% update PATH (this was recommended online, but I think would not work,
% because system('echo -n $PATH') returns the system path, as noted above
% [~,result]=system('echo -n $PATH');
% setenv('PATH',result)
% clear result

% instead, i could add this (and any others I would need):
% setenv('PATH',fullfile(getenv('PATH') ':/usr/local/bin'));
% I added this below

% %% Put /usr/local/bin on path so we can see things installed by Homebrew.
% if ismac()
%     setenv('PATH', ['/usr/local/bin:' getenv('PATH')));
% end

% % add local paths to default PATH to see Homebrew installs etc.
% setenv('PATH',fullfile(getenv('PATH') ':/usr/local/bin:/Users/coop558/.pyenv'));

