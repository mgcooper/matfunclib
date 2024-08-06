function tf = ismapstruct(S)
   %ISMAPSTRUCT Return true if input S is a mapstruct
   %
   %  TF = ISMAPSTRUCT(S)
   %
   % See also isgeostruct

   % parse inputs
   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = mfilename;
      parser.addRequired('S', @isstruct);
      parser.addParameter('require_XY_fieldnames', @islogicalscalar);
   end
   parse(parser, S);
   kwargs = parser.Results;

   % main
   names = parseFieldNames(S);

   tf = ismember('Geometry', names) && ismember('BoundingBox', names);

   if kwargs.require_XY_fieldnames
      tf = tf && all(ismember({'X', 'Y'}, names));

   else
      % Allow x, y, x_eastings, y_northings, etc.
      names = lower(names);
      tf = tf && all(ismember({'x', 'y'}, names)) ...
         || all(ismember({'x_eastings', 'y_northings'}, lower(names)));
   end
end
