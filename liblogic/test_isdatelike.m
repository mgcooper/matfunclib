%TEST_ISDATENUM test isdatelike

% Define test data
T = 20000101;

%% Test function accuracy

% Test function accuracy using assert
expected = true;
returned = isdatelike(T);
assert(isequal(returned, expected));

% Test with edge cases (Inf, NaN, very large/small numbers)
assert(isdatelike(NaN) == false);
assert(isdatelike(Inf) == false);

%% Test type handling

X = now;

expected = true; % double
assert(isequal(isdatelike(X), expected));

expected = true; % single
assert(isequal(isdatelike(single(X)), single(expected)));

expected = true; % int16
assert(isequal(isdatelike(int16(X)), expected)); 

expected = false; % logical 
assert(isequal(isdatelike(logical(X)), expected));

expected = false; % struct
assert(isequal(isdatelike(struct()), expected));

expected = false; % cell
assert(isequal(isdatelike(cell(1)), expected));

%% Test dimension handling

% Test different dimensions
assert(isequal(isdatelike([now; now]), true)); % 1D array
assert(isequal(isdatelike([now now; now now]), true)); % 2D array

%% Test empty inputs
try
   isdatelike();
   error('Expected an error for empty inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:narginchk:notEnoughInputs'));
end

%% Test invalid inputs
% try
%    isdatelike(struct());
%    error('Expected an error for invalid inputs, but none was thrown');
% catch ME
%    % if arguments block is used:
%    assert(strcmp(ME.identifier, 'MATLAB:validation:UnableToConvert'));
%    % otherwise, might be:
%    % assert(strcmp(ME.identifier, 'MATLAB:invalidInput'));
% end

%% Test too many input arguments
try
   isdatelike(1,2,3,4,5,6,7);
   error('Expected an error for too many inputs, but none was thrown');
catch ME
   assert(strcmp(ME.identifier, 'MATLAB:narginchk:tooManyInputs'));
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