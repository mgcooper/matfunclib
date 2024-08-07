function S = geostructinit(geometry, numfeatures, varargin)
   %GEOSTRUCTINIT Initialize a geostructure S with geometry
   %
   %  S = geostructinit(geometry, numfeatures)
   %  S = geostructinit(geometry, numfeatures, 'fieldnames', fieldnames)
   %
   % Description
   %
   %  S = geostructinit(geometry, numfeatures) creates a geostruct S of
   %  size(1,numfeatures) and Geometry 'line', 'point', or 'polygon'.
   %
   %  S = geostructinit(geometry, numfeatures, 'fieldnames', fieldnames) creates
   %  a geostruct S of size(1,numfeatures) and Geometry 'line', 'point', or
   %  'polygon' and fields specified by 'fieldnames' name-value input.
   %
   % Author: Matt Cooper, Sep-23-2022, https://github.com/mgcooper
   %
   % See also: isgeostruct, updateBoundingBox

   persistent parser
   if isempty(parser)
      parser = inputParser();
      parser.FunctionName = mfilename();
      parser.CaseSensitive = false;
      parser.KeepUnmatched = true;
      parser.addRequired('geometry', @ischar);
      parser.addRequired('numfeatures', @isnumeric);
      parser.addParameter('fieldnames', {''}, @ischarlike);
   end
   parse(parser, geometry, numfeatures, varargin{:});
   fieldnames = parser.Results.fieldnames;

   % NOTE: the geostruct will not be a true geostruct until the BoundingBox
   % field is added, which can be achieved with updategeostruct

   % Make sure the geometry is capitalized
   geometry(1) = upper(geometry(1));

   % Initialize a geo struct
   [S(1:numfeatures).Geometry] = deal(geometry);
   [S(1:numfeatures).Lon] = deal(nan);
   [S(1:numfeatures).Lat] = deal(nan);

   for n = 1:numel(fieldnames)
      [S(1:numfeatures).(fieldnames{n})] = deal(nan);
   end

   % if this is done, then subsequent calls to updategeostruct (e.g. after the
   % lat/lon values are filled in) will not create the BoundingBox field, so
   % only do this if lat/lon is provided to this fucntion, which isn't
   % implemented yet)
   % S = updategeostruct(S);
end
