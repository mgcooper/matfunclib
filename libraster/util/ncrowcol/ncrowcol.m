function [start, count] = ncrowcol(ncvar, ncX, ncY, xpoly, ypoly, kwargs)
   %NCROWCOL find start and count indices for netcdf file
   %
   %  [START, COUNT] = NCROWCOL(NCVAR, NCX, NCY, XPOLY, YPOLY)
   %
   % Inputs
   %  ncvar - a variable in the nc file. If
   %  ncX - the X coordinates of the data,
   %  ncY - the Y coordinates of the data, either exactly as returned by ncread,
   %
   % Notes
   %  ncX and ncY must be oriented along the same dimensions as the underlying
   %  gridded data in the nc file. Typically this is ndgrid (row major) format.
   %  If ncX and ncY are passed in as grid vectors, they are converted to
   %  fullgrids using ndgrid.
   %
   %  The purpose of ncvar is to determine the size of the 3rd, 4th, and higher
   %  dimensions if they exist. If these dims are known, it is often easiest to
   %  pass in ncX or ncY for ncvar, e.g.:
   %
   %     [START, COUNT] = NCROWCOL(NCX, NCX, NCY, XPOLY, YPOLY)
   %
   %  If that syntax is used, care must be taken to ensure ncvar (here, ncX) is
   %  oriented like the underlying data. Technically, ncvar only needs to be the
   %  same shape as the underlying data, meaning it does not need to be ordered
   %  the same (it could be S-N instead of N-S but cannot be N-S along the first
   %  dimension if the underlying data is E-W). In general, it is less error
   %  prone to read in one variable, pass it in for ncvar without reorienting
   %  it, along with ncX and ncY as returned by ncread without reorienting them.
   %
   % See also

   arguments
      ncvar
      ncX
      ncY
      xpoly
      ypoly
      kwargs.ncinfo = []
      kwargs.makeplot (1, 1) logical = false
      kwargs.polybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.xpolybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.ypolybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.xcellbuffer (1, 1) {mustBeInteger} = 0
      kwargs.ycellbuffer (1, 1) {mustBeInteger} = 0
   end

   % Assume a data var was provided rather than char variable name
   waschar = ischar(ncvar);
   if waschar
      info = kwargs.ncinfo;
      ivar = ismember({info.Variables.Name}, ncvar);
      varsize = info.Variables(ivar).Size;
   end

   % % check if input is geographic or projected
   % if islatlon(ncY,ncX)
   % end

   % Convert grid vectors to full (nd) grids.
   if isvector(ncX) && isvector(ncY)
      [ncX, ncY] = ndgrid(ncX, ncY);
   end

   % Check if a polygon was provided or just a point
   if numel(xpoly) > 1
      Points = pointsInPoly(ncX, ncY, polyshape(xpoly, ypoly), ...
         buffer=kwargs.polybuffer, ...
         xbuffer=kwargs.xpolybuffer, ...
         ybuffer=kwargs.ypolybuffer);
      inpoly = Points.inpolyb;

      [r, c] = ind2sub(size(inpoly), find(inpoly));
      r = unique(r);
      c = unique(c);
   else
      % Use dsearchn
      knear = dsearchn([ncX(:) ncY(:)], [xpoly ypoly]);
      [r,c] = ind2sub(size(ncX), knear);
      r = unique(r);
      c = unique(c);
      % note: to support multiple nearby neighbors, use findnearby, but
      % that will require more complicated input checks
   end

   % previously I used this for the count, but it is wrong when there is a
   % missing value in the rows or columns i.e. when all(diff(r) == 1) is false
   rowcount = @(r) max(r) - min(r) + 1; % rowcount = @(r) length(unique(r));
   colcount = @(c) max(c) - min(c) + 1; % colcount = @(c) length(unique(c));

   if not(waschar)
      if iscolumn(ncvar)
         start = r(1);
         count = rowcount(r);
      elseif isrow(ncvar)
         start = c(1);
         count = colcount(c);
      elseif ismatrix(ncvar)
         start = [r(1), c(1)];
         count = [rowcount(r), colcount(c)];
      elseif ndims(ncvar) == 3
         start = [r(1), c(1), 1];
         count = [rowcount(r), colcount(c), size(ncvar,3)];
      elseif ndims(ncvar) == 4
         start = [r(1), c(1), 1, 1];
         count = [rowcount(r), colcount(c), size(ncvar,3), size(ncvar,4)];
      else
         warning( ...
            'This function does not support 4-d or higher dimension variables');
      end

   else
      disp(['warning: row/col indexing may be unreliable for 1-d vars ' ...
         newline 'if variable name is provided instead of variable']);

      if numel(varsize) == 1
         start = r(1);
         count = rowcount(r);
      elseif numel(varsize) == 2
         start = [r(1), c(1)];
         count = [rowcount(r), colcount(c)];
      elseif numel(varsize) == 3
         start = [r(1), c(1), 1];
         count = [rowcount(r), colcount(c), varsize(3)];
      elseif numel(varsize) == 4
         start = [r(1), c(1), 1, 1];
         count = [rowcount(r), colcount(c), varsize(3), varsize(4)];
      else
         warning( ...
            'This function does not support 4-d or higher dimension variables');
      end
   end

   % Extend by one row/col in each dimension to ensure full coverage
   [start, count] = extendStartCount(start, count, ncX, ncY, ...
      kwargs.xcellbuffer, kwargs.ycellbuffer);

   if kwargs.makeplot
      figure; hold on
      scatter(ncX(:), ncY(:), 'filled');
      scatter(ncX(inpoly), ncY(inpoly), 'filled')
      plot(xpoly, ypoly);
   end
end

function [start, count] = extendStartCount(start, count, lon, lat, Nx, Ny)
   % Extend start, count by Nx/Ny cells on either side to ensure full coverage.

   nlat = numel(lat);
   nlon = numel(lon);

   % Remove the 3rd and higher dims
   start__ = start(3:end);
   count__ = count(3:end);
   start = start(1:2);
   count = count(1:2);

   % If start != 1, count should be increased by two to account for the extra
   % cell on either side. But if start == 1, then count should be increased by
   % one to extend one cell on the other side. The min(...) condition ensures
   % count += 1 if start == 1. Multiply Nx/Ny by two to account for either side.
   count(1) = count(1) + min(2 * Nx, start(1));
   count(2) = count(2) + min(2 * Ny, start(2));
   start(1) = start(1) - Nx;
   start(2) = start(2) - Ny;

   % Ensure start, count do not extend beyond the size of the data
   start(1) = min(max(start(1), 1), nlon);
   start(2) = min(max(start(2), 1), nlat);
   count(1) = min(max(count(1), 1), nlon - start(1) + 1);
   count(2) = min(max(count(2), 1), nlat - start(2) + 1);

   % Reappend the 3rd and higher dims
   start = [start, start__];
   count = [count, count__];
end
