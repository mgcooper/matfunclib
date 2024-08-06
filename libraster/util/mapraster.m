function mapraster(Z, kwargs)

   % Note: this currently only supports geographic coordinates

   arguments
      Z
      kwargs.RasterReference = []
      kwargs.Lat = []
      kwargs.Lon = []
      kwargs.X = []
      kwargs.Y = []
      kwargs.colormap = []
      kwargs.applyLandMask = false
   end

   [X, Y, Z] = parseinputs(Z, kwargs);

   mask = preparemask(X, Y, Z, kwargs);

   coastlat = load('coastlines.mat').('coastlat');
   coastlon = load('coastlines.mat').('coastlon');

   % Make the figure
   ax = geomap(Y, X);
   hold on

   pcolorm(Y, X, Z)
   plotm(coastlat, coastlon, 'Color', 'k', 'LineWidth', 1);

   if isempty(kwargs.colormap)
      try
         colormap(brewermap(1024, 'OrRd'))
      catch e
         colormap('parula')
      end
   else
      colormap(kwargs.colormap)
   end
   setm(gca, 'ffacecolor', rgb('ocean blue'))
   axis tight

   % c = colorbar('southoutside');
   % c.Label.String = "LWE thickness (m)";

   %geoshow(LAT, LON, LWE0, 'CData', LWEavg, 'DisplayType', 'texturemap');
   %bordersm('countries', 'k')
end


function [X, Y, Z] = parseinputs(Z, kwargs)

   % Determine what was provided
   XYwasprovided = all(~isempty(kwargs.X)) && all(~isempty(kwargs.Y));
   LLwasprovided = all(~isempty(kwargs.Lat)) && all(~isempty(kwargs.Lon));
   RRwasprovided = ~isempty(kwargs.RasterReference);

   if XYwasprovided && LLwasprovided
      error('Provide either X and Y or Lat and Lon but not both')
   end

   if ~XYwasprovided && ~LLwasprovided && ~RRwasprovided
      error('Provide either X and Y, Lat and Lon, or Raster Reference object R')
   end

   % If X and Y were provided use them
   if XYwasprovided
      [X, Y] = validateGridCoordinates(kwargs.X, kwargs.Y, mfilename);

   elseif LLwasprovided
      [X, Y] = validateGridCoordinates(kwargs.Lon, kwargs.Lat, mfilename);

   else

      % If no X,Y or Lat,Lon, use R to create a grid
      [Z, R] = validateRasterReference(Z, kwargs.RasterReference);

      if R.CoordinateSystemType == "geographic"
         [Y, X] = R.geographicGrid;
      else
         [X, Y] = R.worldGrid;
      end
   end

   % If Z is 3d, convert to 2d
   if ndims(Z) == 3
      Z = mean(Z, 3);
   end
   Z0 = zeros(size(Z)); % Z0 is not needed, but is useful for geoshow
end

function mask = preparemask(X, Y, Z, kwargs)
   if kwargs.applyLandMask
      assert(isGeoGrid(Y, X));
      assert(activate('landmask', 'silent', true))
      mask = landmask(Y, X);
   else
      mask = true(size(Z));
   end
   if size(mask) == size(Z)
      Z(~mask) = nan;
   else
      error("mask size does not match grid size")
   end
end
