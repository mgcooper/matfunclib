function [Z, R] = rastercrop(Z, R, varargin)
   %RASTERCROP Crop raster Z to bounding limits
   %
   %    [Z, R] = rastercrop(Z, R, bbox)
   %    [Z, R] = rastercrop(Z, R, xlimits, ylimits)
   %
   %  Description
   %
   %    [Z, R] = rastercrop(Z, R, bbox) Crops raster Z to the bounding box of
   %    polygon(s) bbox. bbox can be a polyshape vector, a "mapstruct", or a
   %    "geostruct".
   %
   % See also

   % Confirm mapping toolbox is installed.
   assert(license('test', 'map_toolbox') == 1, ...
      [mfilename ' requires Matlab''s Mapping Toolbox.'])

   validateRasterReference(Z, R, mfilename)
   switch nargin
      case 3
         [xlims, ylims] = boundingBoxLimits(varargin{1});
         varname = 'bbox';

      case 4
         [xlims, ylims] = deal(varargin{:});
         varname = 'xlims, ylims';

      otherwise
         narginchk(2, 4)
   end
   validateboundingbox([xlims(:) ylims(:)], mfilename, varname, 3)

   if isGeoGrid(ylims, xlims)
      validateRasterReference(Z, R, mfilename, 'geographic')
      [Z, R] = geocrop(Z, R, ylims, xlims);
   else
      validateRasterReference(Z, R, mfilename, 'planar')
      [Z, R] = mapcrop(Z, R, xlims, ylims);
   end
end
