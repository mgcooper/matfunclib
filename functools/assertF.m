function varargout = assertF(cond, varargin)
   %ASSERTF Assert with on/off toggle using control flag and function handle.
   %
   % mode = assertF
   % assertF on
   % assertF off
   % assertF(@() CONDITION)
   % assertF(CONDITION)
   %
   %
   % mode = assertF returns the current assertF mode ('on' or 'off').
   % assertF('on') or assertF('off') toggles assertion checking.
   % assertF(@() CONDITION) checks CONDITION only if assertion checking is on.
   % assertF(CONDITION) always checks CONDITION, ignoring assertion flag.
   %
   % When assertion checking is off, conditions wrapped in function handles
   % are not evaluated, improving performance. The function also supports
   % additional arguments for error IDs and messages, just like MATLAB's
   % built-in assert function.
   %
   % This function was inspired by Dave Ober's assertF function.
   %
   % See also: assert

   persistent assertFlag
   if isempty(assertFlag)
      assertFlag = true;
   end
   mode = ifelse(assertFlag, 'on', 'off');
   nargoutchk(0, 1)
   if nargin == 0
      if ~nargout
         disp(mode)
      end
      [varargout{1:nargout}] = deal(mode);
      return
   end

   % Update flag if 'on' or 'off' is passed as argument
   if nargin == 1 && ischar(cond) || isStringScalar(cond)
      mode = validatestring(cond, {'on', 'off'}, mfilename, 'ASSERTFLAG', 1);
      assertFlag = strcmp(mode, 'on');
      [varargout{1:nargout}] = deal(mode);
      return
   end

   % If cond is not a function handle, it's an evaluated logical statement. If
   % it is a handle and assertFlag is true, cond() will evaluate the handle. In
   % both cases, cond() == false will trigger the assert(false, ...) failure.
   shouldEvaluate = not(isa(cond, 'function_handle')) || assertFlag;

   if shouldEvaluate && cond() == false

      % Next two lines help locate assert issue if assert is caught by try/catch
      % fprintf(1, 'Assertion failed in assertF.\n');
      % dbstack(1);

      % Delegate to built-in assert
      assert(false, varargin{:});
   end
end
