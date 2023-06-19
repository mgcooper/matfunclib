function varargout = setFontSize( fontSize )
%setFontSize Change the size of the environment font
%   Call as setFontSize( fontSize );
%   Inputs:
%     fontSize: the size of the font - must be an integer value

% Get the system settings object
s = settings;

% Return the active font size
if nargin == 0
   varargout{1} = s.matlab.fonts.codefont.Size.ActiveValue;
else
   % Check the input is valid
   assert( rem( fontSize, 1 ) == 0, 'setFontSize:inputType', 'The input must be an integer' );

   % Set the font size to desired value
   s.matlab.fonts.codefont.Size.TemporaryValue = fontSize;

end
