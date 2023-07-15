function result = runtests()
%runtests Run parameterized test suite

% not sure if this depends on Matlab >= 2016
import matlab.unittest.TestSuite

%% Import a parameterized test suite from a directory:
suite = TestSuite.fromFolder('tests', 'IncludingSubfolders', true);
result = transpose(suite.run()); %#ok<*NASGU> 

%% Import a parameterized test suite from a package directory:
suite = TestSuite.fromPackage("tbx.test.ParameterizedTestTbx");
result = transpose(suite.run()); %#ok<*NASGU> 

%% Run a coverage report
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport

suite = TestSuite.fromPackage("tbx.test.ParameterizedTestTbx");
runner = TestRunner.withNoPlugins;
runner.addPlugin(CodeCoveragePlugin.forPackage("tbx.test.ParameterizedTestTbx", ...
   'Producing',CoverageReport('+tbx/+test/tbxCoverageResults', ...
   'MainFile','tbxCoverageTestResults.html')))
runner.run(suite)

%% Import a parameterized test suite from a class directory:
suite = TestSuite.fromClass(?ParameterizedTestTbx);
result = table(suite.run());

%% print the results to the screen (bit more user friendly than the default)
for n = 1:numel(result)
   if result(n).Passed == true
      disp(['Passed Test ' int2str(n)])
   else
      disp(['Failed Test ' int2str(n)])
   end
end

