function varargout = debugmode(mode, varargin)
   %DEBUGMODE Logical flag to control debug mode with on/off toggle.
   %
   %    debugmode()
   %    mode = debugmode()
   %    debugmode on
   %    debugmode off
   %    debugmode('on')
   %    debugmode('off')
   %    mode = debugmode(_)
   %
   %    DEBUGMODE() returns the logical true/false state of the debug mode. Use
   %    debugmode exactly like any other logical true/false switch. This is
   %    especially useful in function development to isolate code which should
   %    only be run in certain circumstances, or is under development, or being
   %    kept around for reference. It is often tempting to comment out these
   %    snippets and later activate them when needed, but then automatic
   %    variable renaming does not work or the comments become distracting.
   %    Place these snippets into an if-else block like this, and toggle
   %    debugmode on or off as desired.
   %
   %        debugmode off
   %        if debugmode
   %           ... code
   %        end
   %
   %    MODE = DEBUGMODE returns the current debugmode mode ('on' or 'off').
   %    DEBUGMODE('on') or DEBUGMODE('off') toggles the true/false state of
   %    debug mode, with 'on' true and 'off' false.
   %
   %  This function was inspired by Dave Ober's assertF function.
   %
   % See also: assertF

   persistent debugFlag
   if isempty(debugFlag)
      debugFlag = false;
   end
   nargoutchk(0, 1)

   % Here, the true/false status is returned as the output argument.
   if nargin == 0
      varargout{1} = debugFlag;
      return
   end

   % Update flag if 'on' or 'off' is passed as argument. Note that here, the
   % 'on' or 'off' state is returned as the output argument.
   if nargin == 1 && ischar(mode) || isStringScalar(mode)
      mode = validatestring(mode, {'on', 'off'}, mfilename, 'DEBUGFLAG', 1);
      debugFlag = strcmp(mode, 'on');
      [varargout{1:nargout}] = deal(mode);
      return
   end
end
