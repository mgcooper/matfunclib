function R = grid2R(X,Y)
   %GRID2R alias for rasterref
   %
   % GRID2R R = grid2R(X,Y) is an alias for rasterref
   %
   % GRID2R R = grid2R(X,Y) constructs spatial referencing object R from 2-d
   % grids of E-W (longitude) and N-S (latitude) coordinates X,Y.
   %
   %   Author: Matt Cooper, guycooper@ucla.edu, June 2019
   %   Citation: Matthew Cooper (2019). matrasterlib
   %   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
   %   DD, YYYY.
   %
   %   Syntax
   %
   %   R = grid2R(X,Y)
   %
   %   Description
   %
   %   R = grid2R(X,Y) constructs spatial referencing object R from 2-d grids
   %   of E-W (longitude) and N-S (latitude) coordinates X,Y. X and Y are 2-d
   %   numeric matrices (grids) of equal size oriented E-W and N-S such that
   %   the linear (row,col) index (1,1) is the northwest corner and the
   %   coordinate pair X(1,1),Y(1,1) is the centroid of the northwest corner
   %   grid cell, consistent with an interpretation of raster grid cell values
   %   representing the centroid of each grid cell. X defines the E-W
   %   (longitude) value of every grid cell and Y defines the N-S (latitude)
   %   value of every grid cell, as would be provided by a netcdf or h5
   %   scientific raster dataset or using [X,Y]=meshgrid(x,y) where x and y
   %   are vectors that span min(x):x_cell_extent:max(x) and
   %   min(y):y_cell_extent:max(y).
   %
   %   See also rasterref, georefcells, maprefcells, meshgrid

   % grid2R is a thin alias for rasterref, as the original author's "I might
   % delete everything in here ... identical to rasterref" note intended. The
   % previous standalone body did NOT match this header's cell-CENTRE convention:
   % it passed the centre min/max straight to maprefcells/georefcells as EDGE
   % limits (no half-cell pad), so the centres landed half a cell off and did not
   % round-trip, and it detected geographic vs planar with the looser islatlon.
   % rasterref applies the centre convention (limits padded half a cell) and the
   % shared isGeoGrid detection, fixing both. See matfunclib-eg3.
   narginchk(2, 2)
   R = rasterref(X, Y);
end
