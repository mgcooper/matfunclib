function tests = test_tbx
   %%TEST_TBX Test the toolbox.
   try
      test_functions = localfunctions(); %#ok<*NASGU>
   catch
      initTestSuite();
   end
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
   % testCase.TestData = generateTestData(funcname);

   % example test data
   % testCase.TestData.S = struct('field1', 'value1', 'field2', 'value2');

   % see various built in "Fixture" functions to perform common setup and
   % teardown tasks. You can also write your own, for example to formalize
   % generateTestData
end

function teardown(testCase) %#ok<INUSD>

end

function test_functionSignatures(testCase)
   % Validate the JSON and get the table
   jsonpath = fullfile(fileparts(fileparts(mfilename("fullpath"))), 'toolbox');
   jsonfile = fullfile(jsonpath, 'functionSignatures.json');
   T = validateFunctionSignaturesJSON(jsonfile);

   % Check if the table is empty
   testCase.verifyEmpty(T, ...
      'The functionSignatures.json file contains invalid entries.');
end

function test_buildpath(testCase)
   toolboxpath = tbx.internal.buildpath('+tbx');
   testCase.verifyTrue(isfolder(toolboxpath), ...
      'Expected +tbx/ folder to exist.');
end

function test_completions(testCase)
   options = tbx.internal.completions('completions');
   for n = 1:numel(options)
      success = true;
      try
         result = tbx.internal.completions(options{n});
      catch
         success = false;
      end
      testCase.verifyTrue(success);
   end
end

function test_privatefunction(testCase)
   func = tbx.internal.privatefunction("isoctave");
   testCase.verifyFalse(func())
end
