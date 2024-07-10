function varargout = runtests(varargin)
   %RUNTESTS Run all tests in the test suite.
   %
   %  result = runtests() Runs all tests in the test/ and/or tests/ folder.
   %  result = runtests(TESTS) Runs all tests in the specified folder(s).
   %  result = runtests(_, 'Debug', true) Runs all tests in verbose debug mode.
   %
   % Note: The only name-value argument currently supported is 'Debug', and in
   % this mode, debugging is configured using the following plugins:
   %
   %  matlab.unittest.Verbosity
   %  matlab.unittest.plugins.DiagnosticsValidationPlugin
   %  matlab.unittest.plugins.StopOnFailuresPlugin
   %
   % Thus the results and/or behavior may differ from those returned by
   % runtests(tests, 'Debug', true).
   %
   % See also: runtests, runperf, testsuite
   %
   % TODO:
   % - Use parseparampairs to support more name-value arguments

   % Parse the test/ path(s) and optional name-value pairs
   if mod(nargin, 2) == 0
      tests = {};
      kwargs = varargin;
   else
      tests = varargin(1);
      kwargs = varargin(2:end);
   end
   tests = parseTestPaths(tests);

   % Run each test suite
   for n = numel(tests):-1:1
      result{n} = runOneSuite(tests{n}, kwargs{:});
   end

   % Parse output
   if numel(result) == 1
      result = result{1};
   end
   if nargout
      varargout = result;
   end
end

function result = runOneSuite(testname, varargin)

   % Import necessary classes
   import matlab.unittest.TestSuite
   import matlab.unittest.TestRunner
   import matlab.unittest.Verbosity
   import matlab.unittest.plugins.DiagnosticsValidationPlugin
   import matlab.unittest.plugins.StopOnFailuresPlugin

   % Uncomment the stuff below this if/when revisiting options to pass in TESTS
   % which are not paths to folders which contain tests. The stuff below was
   % designed to handle package paths differently from regular ones, but I
   % misinterpreted the behavior of fromPackage, which requires pkg.subpkg
   % syntax, not a package path. However, the dot notation could be achieved
   % using mpackagename, which is included below.

   % % This flag specifies whether the test suite is within a +pkg folder
   % % NOTE: This may be incorrect - may need to use <pkgname>.<test
   % pkgflag = contains(testname, '+');
   % pkgname = mpackagename();
   % % In R2022a and later, fromFolder and its name-value options such as
   % % 'IncludingSubfolders' treat +pkg folders the same as regular ones, thus
   % % TestSuite.fromFolder can be used in all cases where testname is a path.
   % % For pre-R2022a, an option to differentiate package paths from regular ones
   % % could be to use the 'BaseFolder' parameter, which I think would be
   % % toolboxpath() or in general:
   %
   % while contains(testname, '+')
   %    testname = fileparts(testname);
   % end
   %
   % % FOR NOW JUST REQUIRE THAT TESTNAME IS A PATH AND USE fromFolder.
   %
   % % Create a test suite from the test/ folder
   % if pkgflag
   %    suite = TestSuite.fromPackage(testname, 'IncludingSubpackages', true);
   % else
   %    suite = TestSuite.fromFolder(testname, 'IncludingSubfolders', true);
   % end

   suite = TestSuite.fromFolder(testname, 'IncludingSubfolders', true);

   if nargin < 2
      % Run parameterized test suite
      result = transpose(suite.run());

      % Print the results to the screen
      for n = 1:numel(result)
         if result(n).Passed == true
            disp(['Passed Test ' int2str(n)])
         else
            disp(['Failed Test ' int2str(n)])
         end
      end
      % To examine failed tests
      % ifailed = find(arrayfun(@(r) r.Failed, results));

   else
      % For verbose and/or debugging
      validatestring(lower(varargin{1}), {'debug'}, mfilename)

      % Create a test runner with detailed text output
      runner = TestRunner.withTextOutput('Verbosity', Verbosity.Detailed);

      % Create a plugin to validate diagnostics. This helps ensure that
      % diagnostic messages are free of errors. The
      % 'IncludingPassingDiagnostics' option means that the plugin checks
      % diagnostics for passing tests as well as failing ones.
      % 'ValidateUsingBaseWorkspace' means that the plugin validates that the
      % diagnostic code can execute in the base workspace without errors.
      %
      % plugin = DiagnosticsValidationPlugin( ...
      %    'IncludingPassingDiagnostics',true,...
      %    'ValidateUsingBaseWorkspace',true);
      %
      % runner.addPlugin(plugin)

      % Add a plugin to stop execution and enter debug mode when a test fails
      runner.addPlugin(StopOnFailuresPlugin)

      % Run the test suite using the configured runner
      result = runner.run(suite);
   end

   % Use built-in runtests with debugging to run function tests:
   % result = runtests(<test_function>, 'Debug', true);

   % % Run a coverage report.
   % % TODO: add 'Coverage' name-value argument.
   % import matlab.unittest.TestSuite
   % import matlab.unittest.TestRunner
   % import matlab.unittest.plugins.CodeCoveragePlugin
   % import matlab.unittest.plugins.codecoverage.CoverageReport
   %
   % suite = TestSuite.fromPackage("tbx.test");
   % runner = TestRunner.withNoPlugins;
   % runner.addPlugin(CodeCoveragePlugin.forPackage( ...
   %    "tbx.test", ...
   %    'Producing',CoverageReport('+tbx/+test/tbxCoverageResults', ...
   %    'MainFile','tbxCoverageTestResults.html')))
   % runner.run(suite)

   % % Import a parameterized test suite from a class directory:
   % suite = TestSuite.fromClass(?ParameterizedTestTbx);
   % result = table(suite.run());
end

function tests = parseTestPaths(tests)

   if isempty(tests)

      % Define the default test/ folders:
      % projectpath/test
      % projectpath/tests
      % projectpath/toolbox/+tbx/test
      % projectpath/toolbox/+tbx/tests

      tests_ = fullfile(projectpath(), ...
         {'test', ...
         'tests', ...
         fullfile('toolbox/+tbx/+test'), ...
         fullfile('toolbox/+tbx/+tests')} ...
         );

      % Determine which of the default test folders exist
      tests = tests_(isfolder(tests_));

      if isempty(tests)
         error(['No test/ or tests/ folder found in top level directory ' ...
            'or toolbox +test directory. ' ...
            'Supply the path as the first argument to this function'])
      end
   else
      % Cast char or string to cellstr
      if isStringScalar(tests)
         tests = {char(tests)};
      elseif isstring(tests)
         tests = cellstr(tests);
      end

      % Instead of validating the supplied tests, let the built-in runner.run
      % parsing catch errors. This way any valid input to runtests can be passed
      % in ... UPDATE: I decided to retain this because I use "fromFolder" to
      % import the test suite, so for now, this function only supports running
      % tests by importing the entire folder suite.
      assert(all(isfolder(tests)))
   end
end
