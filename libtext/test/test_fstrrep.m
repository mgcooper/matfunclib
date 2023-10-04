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


% -------------------------------------
% LOCAL FUNCTIONS
% -------------------------------------
function assertError(fh, eid, varargin)
%ASSERTERROR assert error using function handle and error id

   import matlab.unittest.diagnostics.Diagnostic;
   import matlab.unittest.constraints.Throws;
   
   throws = Throws(eid);
   passed = throws.satisfiedBy(fh);
   diagText = ""; % set empty string for passed == true
   if ~passed
       diag = Diagnostic.join(varargin{:}, throws.getDiagnosticFor(fh));
       arrayfun(@diagnose, diag);
       diagText = strjoin({diag.DiagnosticText},[newline newline]);
   end
   assert(passed, diagText); 
end

function assertSuccess(fnc, eid, varargin)
%ASSERTSUCCESS assert success using function handle and error id

   import matlab.unittest.diagnostics.Diagnostic;
   import matlab.unittest.constraints.Throws;
   
   throws = Throws(eid);
   passed = throws.satisfiedBy(fnc);
   diagText = ""; % set empty string for passed == true
   if passed
       diag = Diagnostic.join(varargin{:}, throws.getDiagnosticFor(fnc));
       arrayfun(@diagnose, diag);
       diagText = strjoin({diag.DiagnosticText},[newline newline]);
   end
   assert(~passed, diagText); 
end

function assertWithAbsTol(returned, expected, tol, varargin)
%ASSERTWITHABSTOL assert equality within an absolute tolerance.
% 
% assertWithAbsTol(returned, expected) uses tol = 1e-6
% assertWithAbsTol(returned, expected, tol)
% assertWithAbsTol(returned, expected, tol, msg)
% 
% Helper function to assert equality within an absolute tolerance.
% Takes two values and an optional message and compares
% them within an absolute tolerance of 1e-6.

if nargin < 4 || isempty(tol), tol = 1e-6; end
   
   tf = abs(returned-expected) <= tol;
   assert(tf, varargin{:});
end

function assertWithRelTol(returned, expected, relTol, varargin)
%ASSERTWITHABSTOL assert equality within a relative tolerance.
% 
%  assertWithRelTol(returned, expected) uses relTol = 0.1%
%  assertWithRelTol(returned, expected, relTol)
%  assertWithRelTol(returned, expected, relTol, msg)
% 
% Helper function to assert equality within a relative tolerance.
% Takes two values and an optional message and compares
% them within a relative tolerance of 0.1%.
   if nargin < 4 || isempty(relTol), relTol = 0.001; end
      
   tf = abs(expected - returned) <= relTol.*abs(expected);
   assert(tf, varargin{:});
end