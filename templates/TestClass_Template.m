classdef TestClass_Template < matlab.unittest.TestCase

   % Notes on general features of MATLAB's testing framework:
   %
   % There are "verifiable", "assertable", and "assumable" qualifications.
   %
   % TLDR: Use verification functions for unit tests (verify*), use assumable
   % (assume*) and assertable (assert*) functions in test setup to validate
   % preconditions of a test, but ensure that your test content is exception
   % safe.
   %
   % Use verification to produce and record failures without throwing
   % exceptions.
   % Use assumptions to ensure the test environment meets preconditions which do
   % not otherwise produce subsequent test failures.
   % Use assertions when the failure invalidates the remaining test content but
   % does not prevent proper execution of subsequent tests.
   % Use fatal assertions to abort the test session upon failure.
   %
   % These can be used in Test, TestMethodSetup, and TestClassSetup methods,
   % which determines how the test content is filtered on failure.
   %
   % Behavior on failures:
   %  verifications: all test content runs to completion.
   %  assumptions: the current test content is marked as Incomplete.
   %  assertions: the current test content is marked as Failed and Incomplete.
   %
   % Assertions prevent unnecessary failures by not performing later
   % verifications that fail due to invalidated preconditions.
   %
   % Assumptions ensure that a test is run only when certain preconditions are
   % met, but running the test without satisfying the preconditions does not
   % produce a test failure. If the unmet preconditions are meant to produce a
   % test failure, use assertions instead of assumptions.
   %

   %
   % Assumptions ensure that a test is run only when certain preconditions are
   % met, but running the test without satisfying the preconditions does not
   % produce a test failure. If the unmet preconditions are meant to produce a
   % test failure, use assertions instead of assumptions
   %
   % However, using
   % If you cannot make the fixture teardown exception safe or restore the
   % environment state after failure, use fatal assertions instead
   %
   % - verification functions (verify*) do not throw exceptions therefore tests
   % run to completion when they fail. Therefore, use other qualification types
   % such as assumable (assume*) or assertable
   % to test for violation of preconditions or incorrect test setup:
   %  - assume* (try doc assume
   %
   % Test content is exception safe when all fixture teardown is performed with
   % the addTeardown method of TestCase or Fixture classes, or when it is
   % performed using object destructors upon a failure. Exception safety ensures
   % that a test failure does not affect subsequent tests even when an exception
   % is thrown.


   % Use the PathFixture class to temporarily add folders to the MATLAB path.
   % When the framework tears down the fixture, it restores the MATLAB path to
   % its previous state.


   % Notes on properties from Mathworks documentation:

   properties
      % a message to preprend to diagnostics. See the Test method example.
      msg = "Equation under test: "
   end


   %% Test Setup and Teardown Methods

   % Notes on setup and teardown methods from Mathworks documentation:

   % "The testing framework guarantees that TestMethodSetup and TestClassSetup
   % methods of superclasses are executed before those in subclasses."

   % "It is good practice for test authors to perform all teardown activities
   % from within the TestMethodSetup and TestClassSetup blocks using the
   % addTeardown method instead of implementing corresponding teardown methods
   % in the TestMethodTeardown and TestClassTeardown blocks. This guarantees the
   % teardown is executed in the reverse order of the setup and also ensures
   % that the test content is exception safe."

   % In the function-based testing documentation, the following is noted:
   %
   % "[fresh fixture functions] are preferred over "file fixture functions" that
   % run once per test file. They are not required, but are used to perform
   % before and after actions. The only input is testCase."
   %
   % Not sure if that extends analogously to TestMethodSetup being preferable to
   % TestClassSetup methods.

   methods(TestClassSetup)
      % Shared setup for the entire test class

      % If assertable qualifications are used in a TestClassSetup fixture, the
      % fixture needs to be exception safe.
      %
      % If you cannot make the fixture teardown exception safe or restore the
      % environment state after failure, use fatal assertions instead

      % Not exception safe:
      % f = figure;
      % testCase.assertEqual(actual,expected)
      % close(f)
      %
      % Exception safe:
      % f = figure;
      % testCase.addTeardown(@close,f)
      % testCase.assertEqual(actual,expected)

      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % PathFixture temporarily adds folders to the path. The path is
         % restored to to its previous state when the fixture is torn down.

         % Note:
         % p = path;
         % testCase.addTeardown(@path, p)
         % ... modify the path

         [testpath, testfile] = fileparts(mfilename("fullpath"));
         projpath = fileparts(testpath);
         tempPath = testCase.applyFixture(PathFixture( ...
            projpath, 'IncludingSubfolders', true));

         % Use an assertion to validate that the fixture has made this TestClass
         % available. If the assertion fails, the framework fails the Test
         % methods without trying to run them.
         testCase.assertNotEmpty(?TestClass_Template)

         % Assert that the path contains the names of the expected subfolders.
         % Replace tempPath.Folders(1) and tempPath.Folders(2) with expected
         % subfolder names.
         import matlab.unittest.constraints.ContainsSubstring
         testCase.assertThat(path, ContainsSubstring(tempPath.Folders(1)))
         testCase.assertThat(path, ContainsSubstring(tempPath.Folders(2)))
      end

      function testPlatform(testCase)
         % An example of an appropriate TestClassSetup method using the
         % matlab.unittest.qualifications.Assertable class method "assertTrue".

         testCase.assertTrue(ismac || isunix, ...
            "Tests must run on a Mac or Linux platform.")
      end
   end

   methods (TestMethodSetup)
      % Setup for each test
      %
      % TestMethodSetup and TestMethodTeardown methods (functions referred to as
      % "Test Fixtures") run before and after each test method.

      % Test fixtures are setup and teardown code that sets up the pretest state
      % of the system and returns it to the original state after running the
      % test. Setup and teardown methods are defined in the TestCase class by
      % the following method attributes

      function manualFixtureFunctionExample(testCase)
         % placeholder function to create a fixture. Normally you would use the
         % PathFixture to achieve this (see TestClassSetup examples).

         p = path;
         testCase.addTeardown(@path, p);
         addpath(fullfile(pwd));
      end

      function withTempFolder(testCase)
         % Create a temporary folder and make it the current working folder.

         % Each test method can write files to the current working folder, which
         % is the temporary folder. After each test method runs, the testing
         % framework restores the working folder to its previous state and
         % deletes the temporary folder.

         import matlab.unittest.fixtures.TemporaryFolderFixture
         import matlab.unittest.fixtures.CurrentFolderFixture

         % Create a temporary folder and make it the current working folder.
         tempFixture = testCase.applyFixture(TemporaryFolderFixture);
         testCase.applyFixture(CurrentFolderFixture(tempFixture.Folder));

         % ... code that should be run in a temporary folder

         % NOTE: the example above can be achieved using WorkingFolderFixture:
         import matlab.unittest.fixtures.WorkingFolderFixture
         testCase.applyFixture(WorkingFolderFixture('TestData', 'TestA'));

         % ... code that should be run in the TestData/TestA subfolder of a
         % temporary folder

      end
   end

   %% Test Methods

   % Notes on Test methods from Mathworks documentation:

   % " ... verifications do not throw exceptions, all test content runs to
   % completion even when verification failures occur ... Use other
   % qualification types to test for violation of preconditions or incorrect
   % test setup:


   methods (Test)
      % Test methods

      function unimplementedTest(testCase)

         diagnostic = [testCase.msg ...
            "(x^2 + 1) + (5*x + 2) = x^2 + 5*x + 3"];

         testCase.verifyEqual(returned, expected, diagnostic)
      end
   end

end
