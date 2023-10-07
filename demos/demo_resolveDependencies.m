clean

% Note: This needs to be updated for latest syntax .

% Test resolveDependencies and getFunctionDependencies

%%

% The outcome of this is that the loop over files in getFunctionDependencies is
% not necessary ad is slow, getRequiredFilesAndPrd does it with a list of files
% so now I just need to determine what should be combined in the resolve step
% between subfucntions of getRequirements/getFunctionDependencies and
% resovleDependencies

% The only other thing I might check is if 'toponly' and recurisively checking
% whihc deps are in theh requirement list and skipping htem is faster but
% presumably requiredFilesAndProducts deos something smart like that

% getFunctionDependencies requires the filename be in matfunclib

% Try getFunctionDependencies with a file name (It won't work with a full-path
% because it uses listallmfiles to validate the function name)
filename = '/Users/coop558/MATLAB/matfunclib/libraster/util/isfullgrid.m';
[folder, filename] = fileparts(filename);
tic; Info1 = getFunctionDependencies(filename); toc
tic; Info2 = getRequirements(filename); toc
isequal(Info1, Info2)

% Try with a folder name
folder = '/Users/coop558/MATLAB/matfunclib/libsys';
tic; Info1 = getFunctionDependencies(folder); toc
tic; Info2 = getRequirements(folder); toc
isequal(Info1, Info2)

% test getFunctionDependencies with a file/folder not on path
folder = '/Users/coop558/myprojects/matlab/bfra/toolbox/+baseflow/+internal';
tic; Info1 = getFunctionDependencies(folder); toc
tic; Info2 = getRequirements(folder); toc
isequal(Info1, Info2)

% test with a file not on path
rmpath('/Users/coop558/MATLAB/matfunclib/libsys/')
cd('/Users/coop558/MATLAB/matfunclib/');
filename = '/Users/coop558/MATLAB/matfunclib/libsys/backupfile.m';
tic; Info1 = getFunctionDependencies(filename); toc
tic; Info2 = getFunctionDependencies(filename); toc

% test with a file not on path w/o extension (should fail)
filename = '/Users/coop558/MATLAB/matfunclib/libsys/backupfile';
tic; Info1 = getFunctionDependencies(filename); toc
tic; Info2 = getFunctionDependencies(filename); toc

% test from within the folder with no extension
cd('/Users/coop558/MATLAB/matfunclib/libsys');
filename = 'backupfile';
tic; Info1 = getFunctionDependencies(filename); toc
tic; Info2 = getFunctionDependencies(filename); toc
isequal(Info1, Info2)

% % Try with a folder list - fails b/c it doesn't support folder lists, but i
% % think that's ok, operating on one folder at a time is reasonable
% folderlist = {
%    '/Users/coop558/MATLAB/matfunclib/libsys'; ...
%    '/Users/coop558/MATLAB/matfunclib/libsys/setFontSize'};
% Info = getFunctionDependencies('funcpath', folderlist);

% now use resolveDependencies

[tf, onpath] = ismfile('/Users/coop558/myprojects/matlab/exactremap/toolbox/enclosedGridCells.m')

tf = ispathlike('/Users/coop558/myprojects/matlab/exactremap/toolbox')


%%

% use enclosedGridCells b/c it depends on files in matfunclib including nested
% files inside sub-folders of libraster.

filename = '/Users/coop558/myprojects/matlab/exactremap/toolbox/enclosedGridCells.m';

[projectFolder, functionName] = fileparts(filename);

cd(projectFolder);

[requirementsList, urlList] = resolveDependencies( ...
   functionName, "projectFolder", projectFolder, "installMissing", true, ...
   "remotebranch", "dev");

% To reconcile getFunctionDependencies with resolveDependencies, test with a
% full projectFolder to eliminate the dir struct
Info = getFunctionDependencies(filename, 'referencePath', projectFolder);

Info = getFunctionDependencies(functionName);



list = listfiles(folderlist, "subfolders", true, "aslist", true, "fullpath", true);
