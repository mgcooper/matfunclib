function [Lat, Lon, cellSizeLat, cellSizeLon, gridType, tfGeoCoords] = ...
      prepareGeoGrid(Lat, Lon, varargin)
   %PREPAREGEOGRID Prepare geographic lat,lon grids for spatial analysis.
   %
   % [Lat, Lon, dLat, dLon, gridType, tfGeoCoords] = prepareGeoGrid(Lat, Lon)
   %
   % Thin GEOGRAPHIC wrapper around prepareMapGrid. It exists so callers can work
   % in LAT,LON order (the convention used across libspatial) rather than the
   % X=Lon, Y=Lat order prepareMapGrid uses. prepareGeoGrid does only the
   % geographic-specific part -- detect and correct a swapped LON,LAT input -- and
   % delegates all grid mechanics (orientation, cell size, gridType, full-grid
   % construction) to prepareMapGrid, which stays coordinate-system agnostic and
   % focused. Outputs mirror prepareMapGrid but in lat-first order.
   %
   % [...] = prepareGeoGrid(Lat, Lon, 'silent', true) suppresses the
   % swapped-order warning.
   %
   % See also: prepareMapGrid, isGeoGrid, orientMapGrid

   p = inputParser;
   p.addParameter('silent', false, @(x) islogical(x) && isscalar(x));
   p.parse(varargin{:});
   silent = p.Results.silent;

   % Detect whether the input is geographic and in lat,lon order. The canonical
   % isGeoGrid signature is isGeoGrid(Lat, Lon); tfLatLonOrder is true when the
   % inputs are already lat,lon, false when they look like lon,lat.
   [tfGeoCoords, tfLatLonOrder] = isGeoGrid(Lat, Lon);

   if tfGeoCoords && ~tfLatLonOrder
      % Geographic but in lon,lat order -> swap to lat,lon.
      [Lat, Lon] = deal(Lon, Lat);
      if ~silent
         warning('prepareGeoGrid:swappedLonLatOrder', ...
            ['Input coordinates appear to be in lon,lat order; swapped to ' ...
            'lat,lon. Pass coordinates as (Lat, Lon) to avoid this.'])
      end
   end

   % Delegate to prepareMapGrid in its X=Lon, Y=Lat order, then map the outputs
   % back to lat-first. prepareMapGrid handles orientation, cell size, gridType,
   % and full-grid construction for both geographic and planar grids.
   [Lon, Lat, cellSizeLon, cellSizeLat, gridType, tfGeoCoords] = ...
      prepareMapGrid(Lon, Lat);
end
