function tf = isgeostruct(S)
   %ISGEOSTRUCT Return true if input S is a geostruct
   %
   %  TF = ISGEOSTRUCT(S)
   %
   % See also

   % parse inputs
   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = mfilename;
      parser.addRequired('S',@isstruct);
   end
   parse(parser, S);

   % main
   tf = isfield(S,'Geometry') && ...
      isfield(S,'BoundingBox') && ...
      any(isfield(S,{'Lat','Latitude'})) && ...
      any(isfield(S,{'Lon','Longitude'}));
end
