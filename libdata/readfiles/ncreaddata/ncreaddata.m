function data = ncreaddata(filename, kwargs)
   %NCREADDATA Read all data in .nc file fname, or all vars in optional list
   %
   %  data = ncreaddata(fname) reads all variables in fname
   %  data = ncreaddata(fname,vars) reads variables vars in fname
   %
   % Required inputs:
   %
   %  fname - full path to .nc file
   %
   % Optional inputs:
   %
   %  varnames - cellstr array of chars that match the variable names in the
   %  .nc file to read. Default behavior reads all variables.
   %
   % Note: the data is converted to column major format
   %
   % See also: ncparse

   % TODO: add grid_mapping. See snowlines/1km-ISMIP6.nc for an example.
   % f = '/Users/mattcooper/work/data/greenland/snowlines/1km-ISMIP6.nc';
   % data = ncreaddata(f);
   % R = rasterref(data.x, data.y);

   arguments
      filename (1, :) char
      kwargs.varnames (1, :) string = string.empty()
      kwargs.reorient (1, 1) logical = true
   end

   fileinfo = ncparse(filename);

   if isempty(kwargs.varnames)
      varnames = string(fileinfo.Name); % Use all varnames
   else
      varnames = kwargs.varnames;
      assert(all(ismember(varnames, fileinfo.Name)))
   end

   data.info = fileinfo;

   % Determine the size of the x,y dimension
   [numx, numy, numt, numz] = getDimensions(fileinfo);

   for n = 1:length(varnames)

      info_n = ncinfo(filename, varnames(n));
      data_n = try_ncread(filename, varnames(n), info_n.Size);

      % Orient the data spatially if >2d and not a known non-spatial case
      if isvector(data_n) || ...
            ismember(info_n.Name, ...
            {'time', 'time_bounds', 'depth'}) % add more as they come up

         % TODO: if 2d, check if one dimension is the size of the time dimension
         data.(varnames(n)) = data_n;
      else
         % This variable > 1 dim, orient it north up, east right
         data.(varnames(n)) = orientGridData(data_n, [numx, numy, numt, numz]);
      end
   end
end

function data_n = try_ncread(filename, varname, varsize)
   try
      data_n = ncread(filename, varname);
   catch ME
      try
         data_n = nan(varsize);
      catch ME2
         if contains(ME2.identifier, 'SizeLimitExceeded')
            data_n = nan;
         else
            rethrow(ME)
         end
      end
   end
end

%% Determine the size and orientation of the data
function [numx, numy, numt, numz] = getDimensions(fileinfo)

   % This subfunction may need to be expanded in scope, and certainly could be
   % improved by utilizing the 'coordinates' attributes of the data if it exists
   % or the standard_names or dimensions. Right now, this basically tries to
   % determine the size of the lat/lon dimensions, which is easiest if lat/lon
   % are vectors but more challenging if they are 2d arrays.

   varnames = string(fileinfo.Name);
   [numx, numy, numt, numz] = deal(nan);
   [ilat, ilon, ix, iy, itime, idepth] = deal(false(numel(varnames), 1));

   % Potential matches. standard_names are first.
   xfields = ["projection_x_coordinate", "x", "x_easting", "x_eastings"];
   yfields = ["projection_y_coordinate", "y", "y_northing", "y_northings"];
   latfields = ["latitude", "lat"];
   lonfields = ["longitude", "lon", "long"];
   timefields = ["time", "date", "dates", "day_of_year"];
   depthfields = ["depth", "depth_below_surface"];

   % First check the standard names
   if isvariable('standard_name', fileinfo)
      ix = ismember(lower(fileinfo.standard_name), xfields);
      iy = ismember(lower(fileinfo.standard_name), yfields);
      ilat = ismember(lower(fileinfo.standard_name), latfields);
      ilon = ismember(lower(fileinfo.standard_name), lonfields);
      itime = ismember(lower(fileinfo.standard_name), timefields);
      idepth = ismember(lower(fileinfo.standard_name), depthfields);
   end

   % If not found, try the varnames
   if none(ix)
      ix = ismember(lower(varnames), xfields);
      iy = ismember(lower(varnames), yfields);
   end
   if none(ilat)
      ilat = ismember(lower(varnames), latfields);
      ilon = ismember(lower(varnames), lonfields);
   end
   if none(itime)
      itime = ismember(lower(varnames), timefields);
   end
   if none(idepth)
      idepth = ismember(lower(varnames), depthfields);
   end

   % If time or depth dimensions were found, return them
   if any(itime)
      numt = fileinfo.Size{itime};
   end
   if any(idepth)
      numz = fileinfo.Size{idepth};
   end

   % Get the size of the x,y dimension according to both x,y and lat,lon
   hasxy = any(ix);
   haslatlon = any(ilat);
   if haslatlon
      numlat = fileinfo.Size{ilat};
      numlon = fileinfo.Size{ilon};
   end
   if hasxy
      numx = fileinfo.Size{ix};
      numy = fileinfo.Size{iy};
   end

   % Determine the size of the x,y dimension
   if haslatlon & numel(numlat) > 1
      if hasxy & numel(numx) == 1
         % Use numx, numy to determine the size of the x,y dimension
      else
         % Both lat/lon and x/y are 2d grids.
         % It is more difficult to determine the size of the x,y dimension.

      end
   elseif haslatlon & numel(numlat) == 1
      % Use numlon, numlat to determine the size of the x,y dimension
      numx = numlon;
      numy = numlat;
   end
end

%% Orient the data north up and east right
function data = orientGridData(data, expected_size)

   numx = expected_size(1);
   numy = expected_size(2);
   numt = expected_size(3);
   numz = expected_size(4);

   actual_size = size(data);

   numrows = actual_size(1);
   numcols = actual_size(2);

   % This orders the data so Y is along columns (1st dim), X along rows (2nd
   % dim), T along pages (3rd dim), and depth along the 4th dim. This might work
   % generally, and then only flipud if the data is known to be gridded and Y
   % increasing down.

   % Note: This was added to deal with data ordered [T, X, Y] or [T, Y, X].
   % Normally the data is [X, Y, T], and permutation is [2 1 3]. This should
   % catch that case too. Not sure what
   newdims = [
      find(actual_size == numy)
      find(actual_size == numx)
      find(actual_size == numt)
      find(actual_size == numz)
      ];

   % Note: if each of the data dimensions match one of the known dim sizes
   % (numx/y/z/t), then newdims will have all of the information needed to
   % reshape the data from it's input shape to the one enforced here: Y,X,T,Z.
   %
   % Note that for a gridcell-based dataset, numx=numy, so newdims could have
   % repeat elements, which is why unique() is applied.
   %
   % But if the data has a dimension size which does not match numx/y/z/t, then
   % the numel(unique(newdims)) will be < ndims(data). This means we cannot
   % reshape the data to the known Y,X,T,Z ordering.
   %
   % This came up when I read a variable (nele) which was N x M, where N = numx
   % = numy (gridcell-based data), and M = 11 did not correspond to any of the
   % dimension variable sizes.
   %
   % In this case, we can use the ones which are found and leave the unmatched
   % dimension to the end or

   if numel(unique(newdims)) == ndims(data)
      data = permute(data, unique(newdims, 'stable'));
   else
      % Handle the case where the data matches some but not all dimension sizes
      % For now, return wihtout modifying the data shape. Need a solution.
      return
   end

   if numrows == numx && numcols == numy
      % The data likely needs to be transposed.
      data = flipud(data);

      % Use this if the newdims method is not working in general
      % data = flipud(permute(data, [2 1 actual_size(3:end)]));

      % This collapses the 3: dimensions
      % data = reshape(data, numrows, numcols, []);
      % data = flipud(permute(data, [2 1 3]));
   end

   % % The original method:
   % data = rot90(fliplr(data));
   %
   % % My standard method:
   % data = flipud(permute(data, [2 1]));
   %
   % % Compare them:
   % M = magic(10);
   % M0 = flipud(permute(M, [2 1 3]));
   % M1 = rot90(M);
   % M2 = rot90(fliplr(M));
   % isequal(M0, M1) % yes
   % isequal(M0, M2) % no
   % isequal(M0, flipud(M2)) % yes
end
