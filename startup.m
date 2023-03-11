% sep 2022: at the end of this script is a copyfile statement that copies
% this to myFunctions/system so i can keep it synced with my other 

% NOTE: MATLABUSERPATH / MATLABHOMEPATH are used in a lot of my new
% functions so don't change the variable name (the values can change)

% SET ENVIRONMENT VARIABLES

% NOTE: the only system (shell) env var I get here is $HOME. I recently changed
% my .bashrc variables to use _ between each word following best practices, but
% I don't think I need to change any here, and therefore my matlab environment
% should not be affected

% userpath is a matlab built-in that returns the matlab startup path. the
% method I use below first sets HOMEPATH, works better than using if/else
% on userpath as long as MATLABUSERPATH is in the same location relative to
% HOMEPATH on all machines. but i use the if/else method to set the python
% path, see further down.

% putting this here so I don't forget it - this should fix the issue where
% blanks are stripped which forces the cursor to the far left in indented code,
% introduced in r2021b
if ~verLessThan('matlab','9.11')
   s = settings;
   s.matlab.editor.indent.RemoveAutomaticWhitespace.PersonalValue = 0;
end

% this can be used to make the desktop display larger, but I usually want the
% opposite, but it can't be set to a number less than 1 which is the default
% s = settings;
% s.matlab.desktop.DisplayScaleFactor.TemporaryValue = 1.2;

% % for reference, there is a smartIndentContents function (method of class
% Document)
% % docs = matlab.desktop.editor.getAll
% % smartIndentContents(docs)
% % save(docs)

HOMEPATH = getenv('HOME'); % system $HOME

setenv('MATLABUSERPATH',fullfile(HOMEPATH,'MATLAB'));

% this is not needed b/c it is equivalent to userpath, but in case I use it
% somewhere else, I am keeping it for now, but delete eventually
% setenv('MATLABSTARTUPPATH',fullfile(getenv('HOME'),'/Documents/MATLAB'));

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

% Set paths - this should negate the need for the stuff below
addpath(genpath(getenv('MATLABUSERPATH')))

% these are interfering with in-built functions or recommended at install
% rmpath(genpath(fullfile(getenv('FEXPACKAGEPATH'),'TEXTBOOKS/Environmental_Modeling')));
% rmpath(genpath(fullfile(getenv('FEXPACKAGEPATH'),'PHYSICS/matlab_sea_ice')));
% rmpath(genpath(fullfile(getenv('FEXPACKAGEPATH'),'PHYSICS/RT_Modest')));
% rmpath(genpath(fullfile(getenv('FEXPACKAGEPATH'),'waterloo')));
% rmpath(genpath(fullfile(getenv('FEXPACKAGEPATH'),'PHYSICS/ResInv3D')));
% rmpath(genpath(fullfile(getenv('FEXFUNCTIONPATH'),'f2matlab')));

%-------------------------------------------------------------------------------
% defaults config
%-------------------------------------------------------------------------------
set(groot                                                   , ...
    'defaultAxesFontName'       ,   'source sans pro'       , ...
    'defaultTextFontName'       ,   'source sans pro'       , ...
    'defaultTextInterpreter'    ,   'Latex'                 , ...
    'defaultAxesFontSize'       ,   16                      , ...
    'defaultTextFontSize'       ,   16                      , ...
    'defaultLineLineWidth'      ,   2                       , ...
    'defaultAxesLineWidth'      ,   1                       , ...
    'defaultPatchLineWidth'     ,   1                       , ...
    'defaultAxesColor'          ,   'w'                     , ...
    'defaultFigureColor'        ,   'w'                     , ...
    'defaultAxesBox'            ,   'off'                    , ...
    'DefaultAxesTickLength'     ,   [0.015 0.02]            , ...
    'defaultAxesTickDir'        ,   'out'                    , ...
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

%------------------------------------------------------------------------------
% Python configuration
%------------------------------------------------------------------------------

if userpath == "/Users/coop558/Documents/MATLAB"
   % % use python 3
   % pyenv('Version','/usr/bin/python3');
   pyenv('Version',fullfile(HOMEPATH,'.pyenv/versions/3.8.5/bin/python3.8'));
   % pyenv('Version',fullfile(HOMEPATH,'.pyenv/shims/python3.8.5'));

elseif userpath == "/Users/mattcooper/Documents/MATLAB"
   % need to figure this out
end


%------------------------------------------------------------------------------
% FINAL STEPS
%------------------------------------------------------------------------------

% activate toolboxes that we want to always be available
activate magicParser
warning off; activate mpm; warning on % in r2022b there is a built in mpm
activate lightspeed

% copy this file to myFunctions where it lives under source control
startupFileNameSource = fullfile(userpath,'startup.m');
startupFileNameDest = fullfile(getenv('MATLABFUNCTIONPATH'),'startup.m');

copyfile(startupFileNameSource,startupFileNameDest);

% turn off the annoying error beep
beep off

% set format for numbers printed to screen so they're readable:
format shortG       % changed to shortG, doc format for examples
format compact    % use pi to see different formats: pi

% clear vars but not the screen b/c it deletes error msgs
clearvars

% open the active project
workon(getactiveproject('name'))

% cd(getenv('MATLABUSERPATH'));

% don't forget
disp('BE GRATEFUL')

%-------------------------------------------------------------------------------

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
% toolboxToolboxDir =fullfile(getenv('SOURCEPATH'),'ToolboxToolbox/'];
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
% 
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
