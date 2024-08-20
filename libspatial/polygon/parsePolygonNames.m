function [names, found, extra, missing] = parsePolygonNames( ...
      namedPolygons, parsedPolygons, expectedNames)
   %PARSEPOLYGONNAMES
   %
   %    names = parsePolygonNames(namedPolygons)
   %    names = parsePolygonNames(namedPolygons, parsedPolygons)
   %    [names, found, extra, missing] = parsePolygonNames(_, expectedNames)
   %
   %  Description
   %    There are two use cases for this function:
   %        * Validate that the names in a NAMEDPOLYGONS string or cellstr list
   %        has one name per element of PARSEDPOLYGONS.
   %        * Obtain NAMES from the 'name' field of a NAMEDPOLYGONS object.
   %    In the first case, the assumption is that NAMEDPOLYGONS either was not
   %    read-in from a shapefile and thus the named-field object representation
   %    of POLYGONS (i.e., struct or table) is unavailable in the calling
   %    workspace, or an alternative list of names which does not match the
   %    'name' field is being used and you simply want to validate the lengths
   %    match (add more use cases as needed).
   %
   %    In the second case, the assumption is that POLYGONS is the
   %
   %  Inputs
   %     NAMEDPOLYGONS - a list of polygon names, or an object (struct or table)
   %     with a 'name' field from which the polygon names can be retrieved.
   %     PARSEDPOLYGONS - a list (cell array, polyshape vector) or struct of
   %     polygons.
   %
   %    This function is meant to be called from, or in tandem with,
   %    parsePolygons. It uses the parsed P returned by parsePolygons. However,
   %    this function can also be used to retrieve the polygon names from a
   %    shapefile attribute table by providing an empty polygonNames input
   %    argument, and in this case, parsedP becomes optional.
   %
   % See also: parsePolygons

   if nargin < 3
      expectedNames = string.empty(1, 0);
   end
   if nargin < 2
      parsedPolygons = namedPolygons;
   end

   % If namedPolygons is a named-fields object, retrieve the 'name' field.
   if isstruct(namedPolygons) || istable(namedPolygons)

      [found, namefield] = isfieldname(namedPolygons, 'name');
      if found
         names = string(...
            matlab.lang.makeValidName({namedPolygons.(string(namefield))}'));
      else
         names = string.empty(1, 0);
      end
   else
      % Ensure that names is returned as a string array if it is a cellstr,
      % char, or string array, otherwise it will be an empty string.
      names = parseFieldNames(namedPolygons);
   end

   if isempty(expectedNames)
      expectedNames = names;
   end

   % If names and expectedNames are both empty strings, this ensures found,
   % extra, and missing are also empty strings.
   [names, found, extra, missing] = parseFieldNames(names, expectedNames);

   % Confirm the number of names matches the number of parsed polygons
   % (nominally returned by parsePolygons). This applies equally to names
   % provided by namedPolygons in list format, or names retrieved from the
   % 'name' field if namedPolygons was an object. 'size' is used so that
   % parsedPolygons can be an Nx2 or 2xN cell array, or an Nx1 or 1xN polygon
   % representation.
   if ~any(numel(found) == size(parsedPolygons))
      warning( ...
         ['Number of polygon names does not match the number of polygons.' ...
         'Ignoring polygon names'])
      namedPolygons = string.empty(1, 0);
   end
end
