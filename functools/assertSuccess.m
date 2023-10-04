function assertSuccess(fnc, eid, varargin)
   %ASSERTSUCCESS Assert success using function handle and error id.
   %
   %  assertSuccess(fh, eid, varargin)
   %
   % See also: assertEqual assertError assertWithRelTol assertWithAbsTol

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