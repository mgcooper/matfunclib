function test_suite = test_internal
   %%TEST_INTERNAL Test the toolbox internal functions.
   %
   %
   %
   % See also

   if ~verLessThan('matlab', '9.0') % Matlab >= 2016

      test_functions = localfunctions(); %#ok<*NASGU>
      test_suite = functiontests(test_functions);

   else % earlier versions: use Mox if it's installed

      % Note: this has not been tested
      try
         initTestSuite();
      catch e

      end
   end
end

% Note: setup and teardown are "fresh fixture functions" that run before and
% after each local test function. They are preferred over "file fixture
% functions" that run once per test file. They are not required, but are used to
% perform before and after actions. The only input is testCase.

% verify<tab> does not complete. For a full list, try:
% doc('Table of Verifications, Assertions, and Other Qualifications')
%
% or doc verifyTrue, then scroll to the bottom for the table

function setup(~)
   % The argument is unused until the commented examples below are enabled;
   % restore the testCase name when enabling them.

   % Save the test data
   % testCase.TestData = tbx.internal.generateTestData(funcname);

   % example test data
   % testCase.TestData.S = struct('field1', 'value1', 'field2', 'value2');

   % see various built in "Fixture" functions to perform common setup and
   % teardown tasks. You can also write your own, for example to formalize
   % generateTestData
end

function teardown(~)

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

function test_privatefunction_unknown_name(testCase)
   % An unmatched name must raise the function's own identified error, not
   % an undefined-variable crash (the search result is initialized so the
   % not-found check is reached).
   testCase.verifyError( ...
      @() tbx.internal.privatefunction("tbx_no_such_function"), ...
      'tbx:privatefunction:functionNotFound')
end

function test_runtests_returns_scalar_result(testCase)
   % A caller requesting an output gets the real TestResult array
   % (varargout{1} = result), not an empty varargout: run a one-test
   % fixture suite in a temp folder through the explicit-folder syntax.
   fixtureDir = fullfile(tempname(), 'test');
   mkdir(fixtureDir)
   cleanup = onCleanup(@() rmdir(fileparts(fixtureDir), 's'));
   writelines([ ...
      "function tests = test_tbxfixture"; ...
      "tests = functiontests(localfunctions);"; ...
      "end"; ...
      "function test_pass(testCase)"; ...
      "verifyTrue(testCase, true)"; ...
      "end"], ...
      fullfile(fixtureDir, "test_tbxfixture.m"));
   returned = tbx.internal.runtests(fixtureDir);
   testCase.verifyClass(returned, 'matlab.unittest.TestResult')
   testCase.verifyNumElements(returned, 1)
   testCase.verifyTrue(returned.Passed)
end
