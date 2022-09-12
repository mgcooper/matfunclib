% see notes at end about path
% sep 2022: at the end of this script is a copyfile statement that copies
% this to myFunctions/system so i can keep it synced with my other 

% NOTE: MATLABUSERPATH / MATLABHOMEPATH are used in a lot of my new
% functions so don't change the variable name (the values can change)

% SET ENVIRONMENT VARIABLES

% note that userpath is a matlab built-in function that returns the path
% where matlab startup is located. an if/elseif statement like below could
% be used to customize two setups, but the method below that first sets
% HOMEPATH works just as well, as long as MATLABUSERPATH is in the same
% location relative to HOMEPATH on both machines. 
% if userpath == "/Users/coop558/Documents/MATLAB"
% elseif userpath == "/Users/mattcooper/Documents/MATLAB"
% end

HOMEPATH    = [getenv('HOME') '/'];          % system $HOME

setenv('MATLABUSERPATH',[HOMEPATH 'MATLAB/']);

% this is not needed b/c it is equivalent to userpath, but in case I use it
% somewhere else, I am keeping it for now, but delete eventually
% setenv('MATLABSTARTUPPATH',[getenv('HOME'),'/Documents/MATLAB']);

% I set this to make the setenv statements syntax more compact:
MATLABPATH  = getenv('MATLABUSERPATH');      % matlab home

setenv('TBDIRECTORYPATH',[MATLABPATH 'templates/']);
setenv('TBJSONACTIVATEPATH',[MATLABPATH 'myFunctions/manager/activate/']);
setenv('TBJSONDEACTIVATEPATH',[MATLABPATH 'myFunctions/manager/deactivate/']);
setenv('FEXFUNCTIONPATH',[MATLABPATH 'fexFunctions/']);
setenv('FEXPACKAGEPATH',[MATLABPATH 'fexPackages/']);
setenv('MATLABFUNCTIONPATH',[MATLABPATH 'myFunctions/']);
setenv('PROJECTDIRECTORYPATH',[MATLABPATH 'templates/']);
setenv('PRJJSONWORKONPATH',[MATLABPATH 'myFunctions/manager/workon/']);
setenv('PRJJSONWORKOFFPATH',[MATLABPATH 'myFunctions/manager/workoff/']);
setenv('MATLABPROJECTPATH',[HOMEPATH 'myprojects/matlab/']);
setenv('MATLABSOURCEPATH',[HOMEPATH 'mysource/matlab/']);
setenv('JIGSAWPATH',[HOMEPATH 'myprojects/jigsaw-matlab/']);
setenv('JIGSAWGEOPATH',[HOMEPATH 'myprojects/jigsaw-geo-matlab/']);

% Set paths - this should negate the need for the stuff below
% addpath(genpath(getenv('MATLABSTARTUPPATH')))
addpath(genpath(getenv('MATLABUSERPATH')))

% these are interfering with in-built functions or recommended at install
rmpath(genpath([getenv('FEXPACKAGEPATH'),'TEXTBOOKS/Environmental_Modeling/']));
rmpath(genpath([getenv('FEXPACKAGEPATH'),'PHYSICS/matlab_sea_ice/']));
rmpath(genpath([getenv('FEXPACKAGEPATH'),'PHYSICS/RT_Modest/']));
rmpath(genpath([getenv('FEXPACKAGEPATH'),'waterloo/']));
% rmpath(genpath([getenv('FEXPACKAGEPATH'),'topotoolbox/topotoolbox/.git']));
rmpath(genpath([getenv('FEXPACKAGEPATH'),'PHYSICS/ResInv3D/'])); 
rmpath(genpath([getenv('FEXFUNCTIONPATH'),'PHYSICS/precise-simulation-featool-multiphysics-f8f8b7e/']));
rmpath(genpath([getenv('FEXFUNCTIONPATH'),'STATISTICS/OPTIMIZE/Mateda3-master/']));
rmpath(genpath([getenv('FEXFUNCTIONPATH'),'f2matlab/']));

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% defaults config
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Python configuration
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % use python 3
% pyenv('Version','/usr/bin/python3');
pyenv('Version',[HOMEPATH '.pyenv/versions/3.8.5/bin/python3.8']);
% pyenv('Version',[HOMEPATH '.pyenv/shims/python3.8.5']);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% FINAL STEPS
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% activate toolboxes that we want to always be available
activate MagicInputParser

% copy this file to myFunctions where it lives under source control
startupFileNameSource   = [userpath '/startup.m'];
startupFileNameDest     = [getenv('MATLABFUNCTIONPATH') 'startup.m'];

copyfile(startupFileNameSource,startupFileNameDest);

% turn off the annoying error beep
beep off

% set format for numbers printed to screen so they're readable:
format shortG       % changed to shortG, doc format for examples
%format compact    % use pi to see different formats: pi

% clear vars but not the screen b/c it deletes error msgs
clearvars

% don't forget
disp('BE GRATEFUL')

cd(getenv('MATLABUSERPATH'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% % additional options I found I wasn't aware of:
% set(groot, ...
% 'DefaultAxesXColor', 'k', ...
% 'DefaultAxesYColor', 'k', ...
% 'DefaultAxesFontUnits', 'points', ...
% 'DefaultTextFontUnits', 'Points', ...

% other good fonts
% fontName = 'Verdana';
% fontName = 'avantgarde';
% fontName = 'BitstreamSansVeraMono';
% fontName = 'Helvetica';
% source sans pro is nice and compact

% % reactivate to work on jigsaw, but better yet, use ToolboxToolbox
% addpath(genpath(getenv('JIGSAWGEOPATH')));
% addpath(genpath(getenv('JIGSAWPATH')));

% note: axes box off does not work because groot applies to low level
% properties, 'plot' is a high level function that puts on the box. setting
% defaultAxesBox off above means that 'line' will not produce a box

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% ToolboxToolbox config
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% toolboxToolboxDir = [getenv('SOURCEPATH'),'ToolboxToolbox/'];
% setenv('TOOLBOXTOOLBOXDIR',toolboxToolboxDir);
% try
%     apiDir = fullfile(toolboxToolboxDir, 'api');
%     cd(apiDir);
%     tbResetMatlabPath('reset', 'full');
% catch err
%     warning(['Error setting ToolboxToolbox path during startup: %s', err.message]);
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
% setenv('PATH', [getenv('PATH') ':/usr/local/bin:/Users/coop558/.pyenv/']);
% 
% addpath(genpath(getenv('STARTUPPATH')))
% addpath(genpath(getenv('HOMEPATH')))

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Python configuration
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
% setenv('PATH', [getenv('PATH') ':/usr/local/bin']);
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
%     setenv('PATH', ['/usr/local/bin:' getenv('PATH')]);
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
