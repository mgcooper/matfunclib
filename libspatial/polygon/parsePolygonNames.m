function polygonNames = parsePolygonNames( ...
      polygonNames, wasfileP, fromfileP, parsedP)
   %PARSEPOLYGONNAMES
   %
   %  polygonNames = parsePolygonNames(polygonNames,wasfileP,fromfileP,parsedP)
   %
   % Note: This function is meant to be called from, or in tandem with,
   % parsePolygons. It uses the parsed P returned by parsePolygons. However,
   % this function can also be used to retrieve the polygon names from a
   % shapefile attribute table by providing an empty polygonNames input
   % argument, and in this case, parsedP becomes optional.
   %
   % See also: parsePolygons

   if isempty(polygonNames) && wasfileP
      [found, name] = isfieldname(fromfileP, 'name');
      if found
         polygonNames = string(...
            matlab.lang.makeValidName({fromfileP.(string(name))}'));
      else
         polygonNames = string.empty(1, 0);
      end
   end

   % If parsedP was not provided, assign it to fromfileP so the warning passes.
   if nargin < 3 || isempty(parsedP)
      parsedP = fromfileP;
   end

   % Confirm the number of names found in "fromfileP" (nominally a shapefile
   % attribute table) match the number of polygons returned by parsePolygons.
   % This applies equally to provided polygonNames or found names.
   if ~isempty(polygonNames) && numel(polygonNames) ~= numel(parsedP)
      warning( ...
         ['Number of polygon names does not match the number of polygons.' ...
         'Ignoring polygon names'])
      polygonNames = string.empty(1, 0);
   end
end
