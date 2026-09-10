function tf = isundefinedfunction(ME)
   %ISUNDEFINEDFUNCTION True when ME reports a function that does not exist.
   %
   %  tf = isundefinedfunction(ME) is true for MATLAB:UndefinedFunction
   %  and Octave:undefined-function, the errors MATLAB and Octave raise
   %  when a name resolves to nothing on the path. It is also true for
   %  Octave's feval form, which carries no identifier and says
   %  "function 'name' not found" or "'name' undefined". Callers that
   %  catch errors around file or registry work test this first, because
   %  a missing function is a code or path defect that a fallback (a
   %  backup file, a per-entry warning) would hide.
   %
   % See also: MException, isoctave

   narginchk(1, 1)
   tf = any(strcmp(ME.identifier, ...
      {'MATLAB:UndefinedFunction', 'Octave:undefined-function'}));
   if ~tf && isempty(ME.identifier)
      msg = ME.message;
      tf = ~isempty(regexp(msg, "^feval: function '.*' not found", 'once')) ...
         || ~isempty(regexp(msg, "^'.*' undefined", 'once'));
   end
end
