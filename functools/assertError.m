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