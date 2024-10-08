%TEST_STACKVARS test stackvars
%#ok<*NASGU>

%%%%%% Shared Data Section

% Define test data
S = struct('field1', 'value1', 'field2', 'value2');

%% Test function accuracy

% Test function accuracy using assert
expected = [];
returned = stackvars( );
assert(isequal(returned, expected));

% Test function accuracy using assert with tolerance
tol = 20*eps;
assert(abs(returned - expected) < tol);

% Test with edge cases (Inf, NaN, very large/small numbers)
assert(isnan(stackvars(NaN)));
assert(isinf(stackvars(Inf)));
assert(abs(stackvars(1e200) - 1e200) < 1e-10); % replace with theoretical result

%% Test error handling

% This uses the custom local functions to mimic the testsuite features like
% verifyError in a script-based testing framework. See the try-catch versions
% further down for another way to test error handling.

testdiag = "description of this test";
eid = 'custom:stackvars:mnemonic';

% verify failure
assertError(@() stackvars('inputs that error'), eid, testdiag)

% verify success
assertSuccess(@() stackvars('inputs that dont error'), eid, testdiag)

%% Test type handling

% Test different types, if the function is expected to handle them

expected = []; % add expected value for double type
assert(isequal(stackvars(X), expected));

expected = []; % add expected value for single type
assert(isequal(stackvars(single(X)), single(expected)));

expected = []; % add expected value for logical type
assert(isequal(stackvars(logical(X)), expected));

expected = []; % add expected value for int16 type
assert(isequal(stackvars(int16(X)), expected)); % int16

%% Test dimension handling

% Test different dimensions
assert(isequal(stackvars([2 3]), [4 6])); % 1D array
assert(isequal(stackvars([2 3; 4 5]), [4 6; 8 10])); % 2D array

%% Test empty inputs
try
   stackvars();
   error('Expected an error for empty inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:minrhs'));
end

%% Test invalid inputs
try
   stackvars('invalid');
   error('Expected an error for invalid inputs, but none was thrown');
catch ME
   % if arguments block is used:
   assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
   % otherwise, might be:
   % assert(strcmp(ME.identifier, 'MATLAB:invalidInput'));
end

%% Test too many input arguments
try
   stackvars(1,2,3,4,5,6,7);
   error('Expected an error for too many inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:TooManyInputs'));
   % if narginchk is used:
   assert(strcmp(ME.identifier, 'MATLAB:narginchk:tooManyInputs'));
end

%%%%%% Define local functions if needed
