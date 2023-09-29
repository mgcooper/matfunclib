function varopen(varargin)
   %VAROPEN Better version of openvar, works with no input and tab-complete
   %
   % NOTE: if in the debugger, will probably fail, see comments below for how to
   % add a check
   %
   % See also: varlist   
  
   if nargin < 1
      list = varlist();
      evalin( 'base', ['open ' list{1}]);
   elseif nargin == 1
      evalin( 'base', ['open ' varargin{1}]);
   elseif nargin == 2
      % varargin{2} is the workspace, either 'base' or 'caller'
      evalin( varargin{2}, ['open ' varargin{1}]);
   end

   % % another way to do it:
   % if nargin < 1
   %    dum = [];
   %    var = 'dum';
   % elseif nargin == 1
   %    var = varargin{1};
   % end
   % com.mathworks.mlservices.MLArrayEditorServices.openVariable(var)

   % these don't work to close the variable so we just get the variable editor
   % com.mathworks.mlservices.MLArrayEditorServices.closeVariable(var)
   % close(var)

   % % this is how it's done in openvar. the if checks if the regular variable editor
   % % should be used, else it would use the JS (java script?) editor for the
   % % debugger. either way, i don't think any of this is needed.
   % matlab.desktop.vareditor.VariableEditor.checkVariableName(var);
   % import matlab.internal.lang.capability.Capability;
   % Capability.require(Capability.InteractiveCommandLine);
   % if isempty(getenv('Decaf')) && Capability.isSupported(Capability.LocalClient)
   %   % Error handling.
   %   matlab.desktop.vareditor.VariableEditor.checkAvailable();
   %   variable = com.mathworks.mlservices.WorkspaceVariableAdaptor(var);
   %   com.mathworks.mlservices.MLArrayEditorServices.openVariable(variable);
   % end

   % matlab.desktop.vareditor.VariableEditor('dum').open
   % matlab.desktop.vareditor.VariableEditor.checkVariableName('dum')
   % matlab.desktop.vareditor.VariableEditor.checkAvailable('dum')
end
