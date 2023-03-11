function setFontSize( fontSize )
%setFontSize Change the size of the environment font
%   Call as setFontSize( fontSize );
%   Inputs:
%     fontSize: the size of the font - must be an integer value
    
    % Check the input is valid
    assert( rem( fontSize, 1 ) == 0, 'setFontSize:inputType', 'The input must be an integer' );

    % Get the system settings object
    s = settings;
    
    % Set the font size to desired value
    s.matlab.fonts.codefont.Size.TemporaryValue = fontSize;
    
end
