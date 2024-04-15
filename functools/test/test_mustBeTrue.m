% function test_mustBeTrue

% This does not work to access verifyError because it requires a testCase object
% import matlab.unittest.qualifications.Verifiable


%% test conversion of logical condition string to function handle

testdiag = "test conversion of logical condition string to function handle";
eid = 'custom:validators:mustBeTrue';

% verify error
assertError(@() mustBeTrue('1<0'), eid, testdiag)

% verify success
assertSuccess(@() mustBeTrue('1>0'), eid, testdiag)

%% test logical condition

testdiag = "test conversion of logical condition string to function handle";
eid = 'custom:validators:mustBeTrue';

% verify failure
assertError(@() mustBeTrue(1<0), eid, testdiag)

% verify success
assertSuccess(@() mustBeTrue(1>0), eid, testdiag)


% LOCAL FUNCTIONS
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

function assertSuccess(fh, eid, varargin)
   %ASSERTSUCCESS assert success using function handle and error id

   import matlab.unittest.diagnostics.Diagnostic;
   import matlab.unittest.constraints.Throws;

   throws = Throws(eid);
   passed = throws.satisfiedBy(fh);
   diagText = ""; % set empty string for passed == true
   if passed
      diag = Diagnostic.join(varargin{:}, throws.getDiagnosticFor(fh));
      arrayfun(@diagnose, diag);
      diagText = strjoin({diag.DiagnosticText},[newline newline]);
   end
   assert(~passed, diagText);
end

function assertWithAbsTol(actVal,expVal,varargin)
   % Helper function to assert equality within an absolute tolerance.
   % Takes two values and an optional message and compares
   % them within an absolute tolerance of 1e-6.
   tol = 1e-6;
   tf = abs(actVal-expVal) <= tol;
   assert(tf, varargin{:});
end

function assertWithRelTol(actVal,expVal,varargin)
   % Helper function to assert equality within a relative tolerance.
   % Takes two values and an optional message and compares
   % them within a relative tolerance of 0.1%.
   relTol = 0.001;
   tf = abs(expVal - actVal) <= relTol.*abs(expVal);
   assert(tf, varargin{:});
end
