% TLDR: This script demonstrates that isfile and isfolder require full paths to 
% reliably identify files in private directories. The 'which' function behaves 
% similarly, but can find files in private directories when called from within 
% the directory.

% Get the current directory so we can return here later
originalDir = pwd;

% Create a temporary directory, switch to it, and add to path
tempDir = fullfile(originalDir, tempfile);
mkdir(tempDir);
cd(tempDir);
addpath(tempDir);

% Create subfolder called 'docs' and a 'private' folder within it
mkdir(fullfile(tempDir, 'private'));

% Create a dummy function file in the 'private' folder
dummyFuncPath = fullfile(tempDir, 'private', 'foo.m');
fid = fopen(dummyFuncPath, 'w');
fprintf(fid, 'function foo()\n disp(''Dummy function called'');\nend');
fclose(fid);

% Run the tests outside of the private folder
disp(isfolder(fullfile(tempDir, 'private')));
disp(isfile(dummyFuncPath));
disp(isfile('foo'));
disp(isfile('foo.m'));
disp(which('foo'));
disp(which('foo.m'));
disp(which('-all', 'foo'));
disp(which('-all', 'foo.m'));

% Go into the private folder
cd(fullfile(tempDir, 'private'));

% Run the tests again
disp(isfile('foo'));
disp(isfile('foo.m'));
disp(which('foo'));
disp(which('foo.m'));

% Cleanup: Remove the temporary directory and return to the original directory
rmpath(tempDir);
cd(originalDir);
rmdir(tempDir, 's');


% 
% % This demonstrates the behavior of isfile, isfolder, which, and which -all for
% % functions in private/ folder.
% 
% % Go out of the private folder
% cd('/Users/coop558/myprojects/matlab/bfra')
% 
% isfolder('/Users/coop558/myprojects/matlab/bfra/docs/private')
% % ans =
% %   logical
% %    1
%    
% isfile('/Users/coop558/myprojects/matlab/bfra/docs/private/foo')
% % ans =
% %   logical
% %    0
%    
% isfile('/Users/coop558/myprojects/matlab/bfra/docs/private/foo.m')
% % ans =
% %   logical
% %    1
% 
% isfile('foo')
% % ans =
% %   logical
% %    0
%    
% isfile('foo.m')
% % ans =
% %   logical
% %    0
% 
% which 'foo'
% % 'foo' not found.
% 
% which 'foo.m'
% % 'foo.m' not found.
% 
% which -all 'foo'
% % /Users/coop558/myprojects/matlab/bfra/docs/private/foo.m  % Private to docs
% 
% which -all 'foo.m'
% % /Users/coop558/myprojects/matlab/bfra/docs/private/foo.m  % Private to docs
% 
% 
% % Go to the private folder
% cd('/Users/coop558/myprojects/matlab/bfra/docs/private')
% 
% isfile('foo')
% % ans =
% %   logical
% %    0
%    
% isfile('foo.m')
% % ans =
% %   logical
% %    1
% 
% which 'foo'
% % /Users/coop558/myprojects/matlab/bfra/docs/private/foo.m  % Private to docs
% 
% which 'foo.m'
% % /Users/coop558/myprojects/matlab/bfra/docs/private/foo.m  % Private to docs
% 
% 
% 
