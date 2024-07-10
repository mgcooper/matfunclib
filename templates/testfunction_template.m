function tests = test_funcname
   %TEST_FUNCNAME test funcname
   tests = functiontests(localfunctions);
end

% Note: setup and teardown are "fresh fixture functions" that run before and
% after each local test function. They are preferred over "file fixture
% functions" that run once per test file. They are not required, but are used to
% perform before and after actions. The only input is testCase.

% verify<tab> does not complete. For a full list, try:
% doc('Table of Verifications, Assertions, and Other Qualifications')
%
% or doc verifyTrue, then scroll to the bottom for the table

function setup(testCase)

   % Save the test data
   testCase.TestData = generateTestData(funcname);

   % example test data
   testCase.TestData.S = struct('field1', 'value1', 'field2', 'value2');

   % see various built in "Fixture" functions to perform common setup and
   % teardown tasks. You can also write your own, for example to formalize
   % generateTestData
end

function teardown(testCase) %#ok<INUSD>

end

function test_input_sign(testCase)
   % Ensure that the function returns the correct value for positive numbers
   returned = funcname(abs(X));
   expected = [];
   verifyEqual(testCase, returned, expected);

   % Ensure that the function returns the correct value for negative numbers
   returned = funcname(-abs(X));
   expected = [];
   verifyEqual(testCase, returned, expected);

   % Ensure that the function returns the correct sum for zero input
   returned = add(0,0);
   expected = 0;
   verifyEqual(testCase, returned, expected);
end

function test_input_validation(testCase)

   % Ensure the function raises an error when given non-scalar inputs
   verifyError(testCase, @()funcname([1,2],3), "MATLAB:validation:IncompatibleSize");

   % Ensure the function raises an error when given non-numeric inputs
   verifyError(testCase, @()funcname(1,"2"), "MATLAB:validators:mustBeNumeric");

   % Ensure the function raises an error when given too few input arguments
   verifyError(testCase, @() funcname(), "MATLAB:minrhs");

   % Ensure the function raises an error when given too many input arguments
   verifyError(testCase, @() funcname(1,2,3,4,5,6,7), "MATLAB:TooManyInputs");

   % Test invalid inputs
   verifyError(testCase, @() numfields('char'), "MATLAB:validation:UnableToConvert");
   % if argument block is used, the eid is MATLAB:validation:UnableToConvert
   % otherwise, it might be MATLAB:invalidInput
end

function test_function_accuracy(testCase)

   TestData = testCase.TestData;

   % Test function accuracy using TestData
   expected = []; %
   returned = funcname(TestData);
   verifyEqual(testCase, returned, expected);

   % verifyEqual(testCase,actual,expected,"AbsTol",abstol,"RelTol",reltol)
   % verifyNotEqual(testCase,actual,expected,"AbsTol",abstol,"RelTol",reltol)

   % verifyTrue
   % verifyFalse
end


