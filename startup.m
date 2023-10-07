% Matlab startup configuration

inoctave = (exist ("OCTAVE_VERSION", "builtin") > 0);
inmatlab = ~inoctave;

%% manage warnings

% Save the current state of the warnings
originalWarningState = warning;

% Create a cleanup object that will be executed when the function is exited
cleanupObj = onCleanup(@() warning(originalWarningState));

% Suppress warnings (e.g., generated by activating mpm)
warning("off", "MATLAB:dispatcher:nameConflict");
warning("off", "MATLAB:rmpath:DirNotFound");
warning("off", "MATFUNCLIB:manager:toolboxAlreadyActive")

%% manage desktop versus command-line settigs

HOMEPATH = getenv('HOME'); % system $HOME

if usejava('desktop') % we're in the desktop (also means we're not in octave)

   % When Matlab is started from the desktop app, it inherits the default system
   % PATH, i.e., these should match:
   % [~, default_path] = system('echo -n $PATH');
   % isequal(default_path, getenv('PATH'))

   % Add brew and pyenv paths to the default system path.
   if ismac()
      setenv('PATH', ...
         fullfile( ...           each line below should be a path followed by ':'
         '/usr/local/bin:', ...
         fullfile(HOMEPATH, '.pyenv:'), ...
         getenv('PATH') ) ...    end fullfile
         );
   end

   % Prevent autoformatter from stripping blanks to prevent the cursor from being
   % forced to the first position in indented code blocks (introduced in r2021b)
   if inmatlab
      % custom desktop settings
      mSettings = settings;

      if ~verLessThan('matlab','9.11')
         mSettings.matlab.editor.indent.RemoveAutomaticWhitespace.PersonalValue = 0;
      elseif verLessThan('matlab','9.14')
         % Make the desktop display larger. A warning is issued on r2023a.
         mSettings.matlab.desktop.DisplayScaleFactor.TemporaryValue = 1.2;
      end
   end

   % smartIndentContents (method of class Document) programmatically formats
   % docs = matlab.desktop.editor.getAll
   % smartIndentContents(docs)
   % save(docs)
else
   % Matlab was started from the terminal, which inherits the PATH variable set
   % by the user dotfiles, so there is no need to set PATH.
end

%% set user paths

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

setenv('GITHUB_USER_NAME', 'mgcooper');

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

% custom remove for octave compatibility
if inoctave
   ignorePaths = [ignorePaths; {
      fullfile(getenv('MATLABFUNCTIONPATH'), 'libtext', 'printf'); ...
      fullfile(getenv('MATLABFUNCTIONPATH'), 'liblogic', 'iscomplex'); ...
      fullfile(getenv('MATLABFUNCTIONPATH'), 'liblogic', 'ifelse'); ...
      fullfile(getenv('MATLABFUNCTIONPATH'), 'libstruct', 'numfields'); ...
      fullfile(getenv('FEXFUNCTIONPATH'), 'libarrays', 'foreach'); ...
      }];
end

for m = 1:numel(ignorePaths)
   subpaths = subpaths(keep(subpaths, ignorePaths{m}));
end

% Rebuild the path string
subpaths = strcat(subpaths, pathsep);
subpaths = horzcat(subpaths{:});

% Add the paths to the path
addpath(subpaths, '-end');


%% Figure defaults

% groot settings apply to low-level properties and therefore low-level functions
% such as 'line', but may not apply to high-level functions such as 'plot'
% (e.g., defaultAxesBox off). However, if 'hold on' is used prior to plot, these
% properties apply. So, in custom plotting functions, begin with 'hold on'.

set(groot                                                      , ...
   'defaultAxesFontName'            ,  'SF Pro Text'           , ...
   'defaultTextFontName'            ,  'SF Pro Text'           , ...
   'defaultTextInterpreter'         ,  'Tex'                   , ...
   'defaultAxesFontSize'            ,  16                      , ...
   'defaultTextFontSize'            ,  16                      , ...
   'DefaultAxesFontUnits'           ,  'points'                , ...
   'DefaultTextFontUnits'           ,  'points'                , ...
   'defaultLineLineWidth'           ,  2                       , ...
   'defaultAxesLineWidth'           ,  1                       , ...
   'defaultPatchLineWidth'          ,  1                       , ...
   'defaultAxesColor'               ,  'w'                     , ...
   'DefaultAxesXColor'              ,  [0.15 0.15 0.15]        , ...
   'DefaultAxesYColor'              ,  [0.15 0.15 0.15]        , ...
   'defaultFigureColor'             ,  'w'                     , ...
   'defaultAxesBox'                 ,  'off'                   , ...
   'DefaultAxesTickLength'          ,  [0.015 0.02]            , ...
   'defaultAxesTickDir'             ,  'out'                   , ...
   'defaultAxesXGrid'               ,  'on'                    , ...
   'defaultAxesYGrid'               ,  'on'                    , ...
   'defaultAxesXMinorGrid'          ,  'off'                   , ...
   'defaultAxesXMinorTick'          ,  'on'                    , ...
   'defaultAxesYMinorGrid'          ,  'off'                   , ...
   'defaultAxesYMinorTick'          ,  'on'                    , ...
   'defaultAxesTickDirMode'         ,  'manual'                , ...
   'defaultAxesMinorGridAlpha'      ,  0.075                   , ...
   'defaultAxesMinorGridLineStyle'  ,  '-'                     );

% xminorgridmode
if inmatlab
   set(groot                                                   , ...
      'defaultAxesXMinorGridMode'      ,  'manual'             , ...
      'defaultAxesYMinorGridMode'      ,  'manual'             , ...
      'defaultAxesXMinorTickMode'      ,  'manual'             , ...
      'defaultAxesYMinorTickMode'      ,  'manual'             );

   beep off
end
%% Environment configuration

format short % careful with shortG, it truncates to 5 digits
format compact % use pi to see different formats: pi

%% activate toolboxes and projects

% active toolboxes
toolboxes = {'magicParser', 'BrewerMap', 'CubeHelix', 'mpm', 'CDT', ...
   'antarctic-mapping-tools', 'arctic-mapping-tools', 'gridbin', 'm_map'};

for n = 1:numel(toolboxes)
   try
      activate(toolboxes{n})
   catch ME
   end
end

% for mpm, put it at the top of the path so built-in mpm becomes shadowed
try
   pathadd(gettbsourcepath('mpm'), true, '-begin')
catch ME

end

% add projects to the path
try
   pathadd(getprjsourcepath('groupstats'), true, '-end')
catch
end

% open the active project if we're in the desktop
if usejava('desktop') && inmatlab
   workon(getactiveproject());
end

%% Python configuration

if inmatlab
   if verLessThan('matlab','9.11') % <r2021b use 3.8
      try
         pyenv('Version', fullfile(HOMEPATH, '.pyenv/versions/3.8.5/bin/python'));
      catch ME
         try
            pyenv('Version', fullfile(HOMEPATH, '.pyenv/shims/python3.8'));
         catch ME
            % pyenv('Version', '/usr/bin/python3')
         end
      end

   else
      try
         pyenv('Version', fullfile(HOMEPATH, '.pyenv/versions/3.9.0/bin/python'));
      catch ME
         try
            pyenv('Version', fullfile(HOMEPATH, '.pyenv/shims/python3.9'));
         catch ME
            % pyenv('Version', '/usr/bin/python3')
         end
      end
   end
end

%% Launch toolboxes
if inmatlab
   try
      ismap(gca);
   catch
   end

   try
      opts = statset();
   catch
   end

   try
      fitoptions();
   catch
   end

   try
      optimoptions("fminunc");
   catch
   end

   try
      imread('ngc6543a.jpg');
   catch
   end
end

%% FINAL STEPS

% clear vars but not the screen b/c it deletes error msgs
clearvars
close all

% don't forget
disp('BE GRATEFUL')

%% Notes

% default font is Monospaced. Some good ones include:
% fontName = 'Verdana';
% fontName = 'avantgarde';
% fontName = 'BitstreamSansVeraMono';
% fontName = 'Helvetica';
% fontName = 'Source Sans Pro' (nice and compact also if bold)