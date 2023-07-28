%TEST_TODATETIME test todatetime

% Define test data
S = struct('field1', 'value1', 'field2', 'value2');

%% Test function accuracy

% Test function accuracy using assert
expected = [];
returned = todatetime( );
assert(isequal(returned, expected));

% Test function accuracy using assert with tolerance
tol = 20*eps;
assert(abs(returned - expected) < tol);

% Test with edge cases (Inf, NaN, very large/small numbers)
assert(isnan(todatetime(NaN)));
assert(isinf(todatetime(Inf)));
assert(abs(todatetime(1e200) - 1e200) < 1e-10); % replace with theoretical result

%% Test error handling

% This uses the custom local functions to mimic the testsuite features like
% verifyError in a script-based testing framework. See the try-catch versions
% further down for another way to test error handling.

testdiag = "description of this test";
eid = 'matfunclib:libname:todatetime';

% verify failure
assertError(@() todatetime('inputs that error'), eid, testdiag)

% verify success
assertSuccess(@() todatetime('inputs that dont error'), eid, testdiag)

%% Test type handling

% Test different types, if the function is expected to handle them

expected = []; % add expected value for double type
assert(isequal(todatetime(X), expected));

expected = []; % add expected value for single type
assert(isequal(todatetime(single(X)), single(expected)));

expected = []; % add expected value for logical type
assert(isequal(todatetime(logical(X)), expected));

expected = []; % add expected value for int16 type
assert(isequal(todatetime(int16(X)), expected)); % int16

%% Test dimension handling

% Test different dimensions
assert(isequal(todatetime([2 3]), [4 6])); % 1D array
assert(isequal(todatetime([2 3; 4 5]), [4 6; 8 10])); % 2D array

%% Test empty inputs
try
   todatetime();
   error('Expected an error for empty inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
end

%% Test invalid inputs
try
   todatetime('invalid');
   error('Expected an error for invalid inputs, but none was thrown');
catch ME
   % if arguments block is used:
   assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
   % otherwise, might be:
   % assert(strcmp(ME.identifier, 'MATLAB:invalidInput'));
end

%% Test too many input arguments
try
   todatetime(1,2,3,4,5,6,7);
   error('Expected an error for too many inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
end


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