%TEST_FSTRREP test fstrrep

% Create a test file
filename = [tempfile '.txt'];
fid = fopen(filename, 'wt');
fprintf(fid, 'oldstring');
fclose(fid);

%% Test function accuracy

% Call the fstrrep function
fstrrep(filename, 'old', 'new', 'backup', false);

% Define the expected result
expected = 'newstring';

% Verify the result
fid = fopen(filename, 'r');
returned = fscanf(fid, '%c');
fclose(fid);

assert(strcmp(returned, expected), 'Replacement failed.');

% Clean up
delete(filename);

%% Test empty inputs
try
   fstrrep();
   error('Expected an error for empty inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
end

%% Test invalid numeric inputs
try
   fstrrep(magic(3), 'old', 'new');
   error('Expected an error for invalid inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:validation:IncompatibleSize'));
end

%% Test invalid file name input
try
   fstrrep(tempfile, 'old', 'new');
   error('Expected an error for invalid inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:validators:mustBeFile'));
end

%% Test too many input arguments
try
   fstrrep(1,2,3,4,5,6,7);
   error('Expected an error for too many inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
end

%% Test error handling

% This uses the custom local functions to mimic the testsuite features like
% verifyError in a script-based testing framework. See the try-catch versions
% further down for another way to test error handling.

% testdiag = "description of this test";
% eid = 'matfunclib:libtext:fstrrep';
% 
% % verify failure
% assertError(@() fstrrep('inputs that error'), eid, testdiag)
% 
% % verify success
% assertSuccess(@() fstrrep('inputs that dont error'), eid, testdiag)

%% Test type handling

% Test different types, if the function is expected to handle them

% expected = []; % add expected value for double type
% assert(isequal(fstrrep(X), expected));
% 
% expected = []; % add expected value for single type
% assert(isequal(fstrrep(single(X)), single(expected)));
% 
% expected = []; % add expected value for logical type
% assert(isequal(fstrrep(logical(X)), expected));
% 
% expected = []; % add expected value for int16 type
% assert(isequal(fstrrep(int16(X)), expected)); % int16

%% Test dimension handling

% % Test different dimensions
% assert(isequal(fstrrep([2 3]), [4 6])); % 1D array
% assert(isequal(fstrrep([2 3; 4 5]), [4 6; 8 10])); % 2D array
