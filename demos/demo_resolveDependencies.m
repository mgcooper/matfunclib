clean

% Demonstrate how to use installRequiredFiles and getRequiredFiles

% see icemodel for combined "install" function.

%% Demo getRequiredFiles

filename = '/Users/coop558/MATLAB/matfunclib/libraster/util/isfullgrid.m';
[folder, filename] = fileparts(filename);

% Simplest use - with filename
Info = getRequiredFiles(filename);

% With folder
Info = getRequiredFiles(folder);

% Supply a reference folder to exclude
Info = getRequiredFiles(filename, ...
   reference="/Users/coop558/MATLAB/matfunclib/libraster/");

% Using the folder
Info = getRequiredFiles(folder, ...
   reference="/Users/coop558/MATLAB/matfunclib/libraster/");

% Multiple reference folders
Info = getRequiredFiles(filename, ...
   reference=["/Users/coop558/MATLAB/matfunclib/libraster/", ...
   "/Users/coop558/MATLAB/matfunclib/libcells/"]);

% All reference folders needed to satisfy all requirements
Info = getRequiredFiles(filename, ...
   reference=["/Users/coop558/MATLAB/matfunclib/libraster", ...
   "/Users/coop558/MATLAB/matfunclib/libcells",...
   "/Users/coop558/MATLAB/matfunclib/functools", ...
   "/Users/coop558/MATLAB/matfunclib/liblogic"]);

% Save the requirements file
Info = getRequiredFiles(filename, ...
   reference="/Users/coop558/MATLAB/matfunclib/libraster/", ...
   saveRequirementsFile=true);

%% installRequiredFiles

% use enclosedGridCells b/c it depends on files in matfunclib including nested
% files inside sub-folders of libraster.

filename = '/Users/coop558/myprojects/matlab/exactremap/toolbox/enclosedGridCells.m';

[projectFolder, functionName] = fileparts(filename);

cd(projectFolder);

% Note - the behavior of installRequiredFiles changed, it no longer accepts a
% function name, it accepts the list or uses the project folder, so send it the
% list generatd by getRequiredFiles to test with a specific function - this used
% to deliberately test with enclosedGridCells. I removed that as the first
% argument and confirmed the syntax below works to generate the full toolbox
% dependency folder for exact remap

[requirementsList, urlList] = installRequiredFiles( ...
   projectPath=projectFolder, ...
   installPath=fullfile(projectFolder, "dependencies"), ...
   installMissing=true, ...
   remoteBranch="dev");

%% Below here the original tests

% Try with a folder name
folder = '/Users/coop558/MATLAB/matfunclib/libsys';
Info = getRequiredFiles(folder);

% test getRequiredFiles with a file/folder not on path
folder = '/Users/coop558/myprojects/matlab/bfra/toolbox/+baseflow/+internal';
Info = getRequiredFiles(folder);

% test with a file not on path
rmpath('/Users/coop558/MATLAB/matfunclib/libsys/')
cd('/Users/coop558/MATLAB/matfunclib/');
filename = '/Users/coop558/MATLAB/matfunclib/libsys/backupfile.m';
Info = getRequiredFiles(filename);

% test with a file not on path w/o extension (should fail)
filename = '/Users/coop558/MATLAB/matfunclib/libsys/backupfile';
Info = getRequiredFiles(filename);

% test from within the folder with no extension
cd('/Users/coop558/MATLAB/matfunclib/libsys');
filename = 'backupfile';
Info = getRequiredFiles(filename);

% % Try with a folder list - fails b/c it doesn't support folder lists, but i
% % think that's ok, operating on one folder at a time is reasonable
% folderlist = {
%    '/Users/coop558/MATLAB/matfunclib/libsys'; ...
%    '/Users/coop558/MATLAB/matfunclib/libsys/setFontSize'};
% Info = getRequiredFiles('funcpath', folderlist);

% now use installRequiredFiles

% [tf, onpath] = ismfile( ...
%    '/Users/coop558/myprojects/matlab/exactremap/toolbox/enclosedGridCells.m')
% tf = ispathlike('/Users/coop558/myprojects/matlab/exactremap/toolbox')

%%



