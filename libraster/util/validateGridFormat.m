function GridFormat = validateGridFormat(GridFormat, validFormats)
   %VALIDATEGRIDFORMAT Validate map grid format.
   %
   %  GridFormat = validateGridFormat(GridFormat, validFormats)
   %
   % See also: validateGridCoordinates, validateGridData

   if nargin < 2
      validFormats = ["point", "fullgrids", "gridvectors", ...
         "coordinates", "unstructured", "unspecified", "unknown"];
   end

   GridFormat = validatestring(GridFormat, validFormats);
end
