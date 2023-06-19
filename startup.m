% Matlab startup configuration

mSettings = settings;

% Prevent autoformatter from stripping blanks to prevent the cursor from being
% forced to the first position in indented code blocks (introduced in r2021b)
if ~verLessThan('matlab','9.11')
   mSettings.matlab.editor.indent.RemoveAutomaticWhitespace.PersonalValue = 0;
end

% Make the desktop display larger.
mSettings.matlab.desktop.DisplayScaleFactor.TemporaryValue = 1.2;

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

% jigsaw
% setenv('JIGSAWPATH',fullfile(HOMEPATH,'myprojects/jigsaw-matlab'));
% setenv('JIGSAWGEOPATH',fullfile(HOMEPATH,'myprojects/jigsaw-geo-matlab'));

% e3sm
setenv('E3SMINPUTPATH',fullfile(getenv('USERDATAPATH'),'e3sm/input'));
setenv('E3SMOUTPUTPATH',fullfile(getenv('USERDATAPATH'),'e3sm/output'));
setenv('E3SMTEMPLATEPATH',fullfile(getenv('USERDATAPATH'),'e3sm/templates'));


% icemodel
setenv('ICEMODELDATAPATH',fullfile(getenv('MATLABPROJECTPATH'),'runoff/data/icemodel/eval'));
setenv('ICEMODELINPUTPATH',fullfile(getenv('MATLABPROJECTPATH'),'runoff/data/icemodel/input'));
setenv('ICEMODELOUTPUTPATH',fullfile(getenv('MATLABPROJECTPATH'),'runoff/data/icemodel/output'));


% Set paths - this should negate the need for the stuff below
addpath(genpath(getenv('MATLABUSERPATH')))

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

   % dont think I want to use system pythong
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

% activate toolboxes that we want to always be available
withwarnoff("MATLAB:dispatcher:nameConflict"); % for mpm
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

% % reactivate to work on jigsaw, but better yet, use ToolboxToolbox
% addpath(genpath(getenv('JIGSAWGEOPATH')));
% addpath(genpath(getenv('JIGSAWPATH')));

% note: axes box off does not work because groot applies to low level
% properties, 'plot' is a high level function that puts on the box. setting
% defaultAxesBox off above means that 'line' will not produce a box

%% ToolboxToolbox config
% 
% toolboxToolboxDir = fullfile(getenv('SOURCEPATH'),'ToolboxToolbox/'];
% setenv('TOOLBOXTOOLBOXDIR',toolboxToolboxDir);
% try
%     apiDir = fullfile(toolboxToolboxDir, 'api');
%     cd(apiDir);
%     tbResetMatlabPath('reset', 'full');
% catch err
%     warning(['Error setting ToolboxToolbox path during startup: %s', err.message));
% end
% 
% cd(getenv('HOMEPATH'));
% 
% % Matlab preferences that control ToolboxToolbox.
% % clear old preferences, so we get a predictable starting place.
% if (ispref('ToolboxToolbox'))
%     rmpref('ToolboxToolbox');
% end
% 
% % add local paths to default PATH to see Homebrew installs etc.
% setenv('PATH',fullfile(getenv('PATH') ':/usr/local/bin:/Users/coop558/.pyenv'));
% 
% addpath(genpath(getenv('STARTUPPATH')))
% addpath(genpath(getenv('HOMEPATH')))

%% Python configuration

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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% rootpath = '/Users/coop558/Dropbox/MATLAB/';
% cd(rootpath);

% rootpath = '/Volumes/GoogleDrive/My Drive/MATLAB/';
%cd(rootpath);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% % % %  THESE COMMENTED OUT WITH NEW METHODS ABOVE
% % jan 2022: matlab seems to be opening in the latest working directory in
% % which case this isn't working as expected so i added this cd to default
% cd('/Users/coop558/Documents/MATLAB/')
% a = pwd; p = genpath(a); addpath(p);
% 	
% % nov 2021, changed rootpath = to userpath('') (changed back, don't use!)
% rootpath = '/Users/coop558/MATLAB/'; cd(rootpath);
% a = pwd; p = genpath(a); addpath(p);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % a reasonable default, or pick your own
% pathString = userpath();
% if isempty(pathString)
%     % userpath() was not set, try to choose a "home" folder
%     if ispc()
%         userFolder = fullfile(getenv('HOMEDRIVE'), getenv('HOMEPATH'));
%     else
%         userFolder = getenv('HOME');
%     end
% else
%     % take the first folder on the userpath
%     firstSeparator = find(pathString == pathsep(), 1, 'first');
%     if isempty(firstSeparator)
%         userFolder = pathString;
%     else
%         userFolder = pathString(1:firstSeparator-1);
%     end
% end
% toolboxToolboxDir = fullfile(userFolder, 'ToolboxToolbox');
% 
% 
% %% Set up the path.
% originalDir = pwd();
% 
% try
%     apiDir = fullfile(toolboxToolboxDir, 'api');
%     cd(apiDir);
%     tbResetMatlabPath('reset', 'full');
% catch err
%     warning('Error setting ToolboxToolbox path during startup: %s', err.message);
% end
% 
% cd(originalDir);
% 
% 
% %% Put /usr/local/bin on path so we can see things installed by Homebrew.
% if ismac()
%     setenv('PATH', ['/usr/local/bin:' getenv('PATH')));
% end
% 
% 
% %% Matlab preferences that control ToolboxToolbox.
% 
% % clear old preferences, so we get a predictable starting place.
% if (ispref('ToolboxToolbox'))
%     rmpref('ToolboxToolbox');
% end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
