function tests = test_funcname
   %TEST_FUNCNAME test funcname
   tests = functiontests(localfunctions);
end

% Notes on function testing framework:
%
% If verify<tab> does not autocomplete, to get a full list, try:
%  doc verifyTrue
% Then scroll to the bottom for the complete table.
% Also see the list at the bottom of this file.
%
% Unfortunately, this does not work:
%  doc('Table of Verifications, Assertions, and Other Qualifications')

% Notes from Mathworks documentation:

% "File fixtures consist of setup and teardown functions shared across all the
% tests in a file. These functions are executed once per test file. Fresh
% fixtures consist of setup and teardown functions that are executed before and
% after each local test function."

% The "setup" and "teardown" functions are "fresh fixture functions" which run
% before and after each local test function. They are preferred over "file
% fixture functions" that run once per test file. They are not required, but are
% used to perform before and after actions. The only input is testCase.

function setup(testCase)

   % Function that generates test data
   % testCase.TestData = generateTestData(funcname);

   % Generate test data
   testCase.TestData.S = struct('field1', 'value1', 'field2', 'value2');

   % see various built in "Fixture" functions to perform common setup and
   % teardown tasks. You can also write your own, for example to formalize
   % generateTestData
end

function teardown(testCase) %#ok<INUSD>

end

% Notes from Mathworks documentation:

% "Each of the local test functions must accept a single input, which is a
% function test case object, testCase."


function test_input_sign(testCase)
   % Ensure that the function returns the correct result for positive numbers
   returned = funcname(abs(X));
   expected = [];
   testCase.verifyEqual(returned, expected);

   % Ensure that the function returns the correct result for negative numbers
   returned = funcname(-abs(X));
   expected = [];
   testCase.verifyEqual(returned, expected);

   % Ensure that the function returns the correct result for zero input
   returned = funcname(0, 0);
   expected = 0;
   testCase.verifyEqual(returned, expected);
end

function test_input_validation(testCase)

   % Ensure the function raises an error when given non-scalar inputs
   testCase.verifyError(@() ...
      funcname([1,2],3), "MATLAB:validation:IncompatibleSize");

   % Ensure the function raises an error when given non-numeric inputs
   testCase.verifyError(@() ...
      funcname(1,"2"), "MATLAB:validators:mustBeNumeric");

   % Ensure the function raises an error when given too few input arguments
   testCase.verifyError(@() ...
      funcname(), "MATLAB:minrhs");

   % Ensure the function raises an error when given too many input arguments
   testCase.verifyError(@() ...
      funcname(1,2,3,4,5,6,7), "MATLAB:TooManyInputs");

   % Test invalid inputs
   testCase.verifyError(@() ...
      funcname('invalid_input'), "MATLAB:validation:UnableToConvert");
   % if argument block is used, the eid is MATLAB:validation:UnableToConvert
   % otherwise, it might be MATLAB:invalidInput
end

function test_function_accuracy(testCase)

   TestData = testCase.TestData;

   % Test function accuracy using TestData
   expected = [];
   returned = funcname(TestData);
   testCase.verifyEqual(returned, expected);

   % testCase.verifyEqual(actual,expected,"AbsTol",abstol,"RelTol",reltol)
   % testCase.verifyNotEqual(actual,expected,"AbsTol",abstol,"RelTol",reltol)
end

% verifyTrue
% verifyFalse
% verifyEqual
% verifyNotEqual
% verifySameHandle
% verifyNotSameHandle
% verifyReturnsTrue
% verifyFail
% verifyThat
% verifyError
% verifyWarning
% verifyWarningFree
% verifyGreaterThan
% verifyGreaterThanOrEqual
% verifyLessThan
% verifyLessThanOrEqual
% verifyEmpty
% verifyNotEmpty
% verifySize
% verifyLength
% verifyNumElements
% verifyClass
% verifyInstanceOf
% verifySubstring
% verifyMatches
