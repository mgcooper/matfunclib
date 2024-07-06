function UseGeoCoordsValue = parseGeoCoordsChoice(DetectedGeoCoords, ...
      UseGeoCoordsValue, UseGeoCoordsDefaultValue, isUsingDefaultValue, kwargs)
   %PARSEGEOCOORDSCHOICE
   %
   % UseGeoCoords = parseGeoCoordsChoice(DetectedGeoCoords, UseGeoCoords, ...
   %     UseGeoCoordsDefaultValue, UsingDefaultValue, silent)
   %
   % This function handles conflicts between the detection of geographic
   % coordinates and user-specified decision to use geographic coordinates.
   %
   % Inputs
   %  DetectedGeoCoords - logical flag indicating that geographic coordinates
   %  were detected.
   %
   %  UseGeoCoords - user-specified logical flag to use geographic coordinates.
   %
   %  UseGeoCoordsDefaultValue - the default value in the input parser.
   %
   %  UsingDefaultValue - true if the default value is being used, false if the
   %  user provided a value to the input parser.
   %
   %  silent - flag that controls the warning output.
   %
   % See also: isGeoGrid

   arguments
      DetectedGeoCoords (1, 1) logical
      UseGeoCoordsValue (1, 1) logical
      UseGeoCoordsDefaultValue (1, 1) logical
      isUsingDefaultValue (1, 1) logical
      kwargs.silent (1, 1) logical = false
      kwargs.caller string {mustBeScalarOrEmpty} = []
      kwargs.stacklevel {mustBeInteger} = []
   end

   % Get the calling function name
   if isempty(kwargs.caller)
      if isempty(kwargs.stacklevel)
         kwargs.stacklevel = numel(dbstack('-completenames')) + 1;
      end
      kwargs.caller = mcallername(stacklevel=kwargs.stacklevel);
   end
   kwargs.caller = upper(kwargs.caller);

   % Initialize the warning message
   msg = "";

   % Determine if the default is being used without user specification
   UsingTrueByDefault = UseGeoCoordsDefaultValue && isUsingDefaultValue;
   UsingFalseByDefault = not(UsingTrueByDefault) && isUsingDefaultValue;

   DetectedMapCoords = not(DetectedGeoCoords);

   if DetectedGeoCoords == UseGeoCoordsValue
      % No conflict with user preference
      return

   elseif DetectedGeoCoords && not(UseGeoCoordsValue)
      % Detected geographic, but user specified or defaulted to false.

      if UsingFalseByDefault
         msg = "Detected geographic coordinates. " ...
            + "Set UseGeoCoords=false in " + kwargs.caller + " to override.";

         UseGeoCoordsValue = true;  % Override based on detection

      else
         % User explicitly specified projected, warn about the contradiction.
         msg = "Detected geographic coordinates " ...
            + "but UseGeoCoords was set false in " + kwargs.caller ...
            + ". Assuming projected coordinate system.";

         UseGeoCoordsValue = false;  % Respect user's choice despite detection
      end

   elseif DetectedMapCoords && UseGeoCoordsValue
      % Detected projected coordinates, but user specified geographic.

      if UsingTrueByDefault
         msg = "Detected projected coordinates. " ...
            + "Set UseGeoCoords=true in " + kwargs.caller + " to override.";

         UseGeoCoordsValue = false;  % Override based on detection
      else
         % User explicitly specified geographic, warn about the contradiction.
         msg = "Detected projected coordinates " ...
            + "but UseGeoCoords was set true in " + kwargs.caller ...
            + ". Assuming geographic coordinate system.";

         UseGeoCoordsValue = true;  % Respect user's choice despite detection
      end
   end

   % Output the warning message if not silent
   if not(kwargs.silent) && not(isempty(msg))
      warning(msg + " Set silent=true to turn off this warning.")
   end
end
