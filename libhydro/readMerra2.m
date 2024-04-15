function [dataGrid, dataList, unit] = readMerra2(filename, varname, varargin)
   %READMERRA2 read data from merra2 .nc file
   %
   %  [DATAGRID, DATALIST] = READMERRA2(FILENAME, VARNAME)
   %  [DATAGRID, DATALIST] = READMERRA2(FILENAME, VARNAME, NCSTART, NCCOUNT)
   %
   %  [_, UNIT] = READMERRA2(FILENAME, VARNAME, UNIT)
   %  [_, UNIT] = READMERRA2(FILENAME, VARNAME, NCSTART, NCCOUNT, UNIT)
   %
   % Description
   %
   %  [DATAGRID, DATALIST] = READMERRA2(FILENAME, VARNAME) reads the data from
   %  variable `varname` contained in the MERRA2 .nc file specified by
   %  `filename`. `dataGrid` contains the data reshaped to column-major format
   %  as a data grid (matrix). `dataList` contains the data reshaped to
   %  list-format.
   %
   %  [DATAGRID, DATALIST] = READMERRA2(FILENAME, VARNAME, NCSTART, NCCOUNT)
   %  reads data beginning at the location of each dimension specified in
   %  `start`. The `count` argument specifies the number of elements to read
   %  along each dimension.
   %
   %  [DATAGRID, DATALIST, UNIT] = READMERRA2(_, UNIT) uses the unit specified
   %  by input argument `unit` to convert the variable to a pre-defined standard
   %  output `unit`. For example, mass fluxes stored in Merra2 files in units
   %  kg/m2/s are converted to m/hr. Temperature data stored in units Celsius
   %  are converted to Kelvins. If the provided value for unit is not
   %  recognized, the variable is not converted. Use with either of the two
   %  prior syntaxes.
   %
   % REQUIRED INPUTS
   %     filename - full path to .nc file
   %     varname  - character array or cellstr of variabe name to read
   %
   % OPTIONAL INPUTS
   %     ncstart  - numeric vector of positive integers representing the
   %                starting location along each data dimension.
   %     nccount  - numeric vector of positive integers representing the number
   %                of elements to read along each data dimension.
   %     unit     - character array specifying the unit of the variable to read
   %
   % OUTPUTS
   %   dataGrid   - the data stored as a spatial grid in column-major format
   %   dataList   - the data stored as a spatial list
   %   unit       - the unit of the data in dataGrid and/or dataList
   %
   %  Note on temporal posting:
   %
   %  Merra-2 data is posted at 3-hour time intervals. Variables that represent
   %  mass fluxes (such as runoff) are converted by this function from kg/m2/s
   %  to m/h, meaning they represent 3-hour averages. To accumulate fluxes,
   %  multiply the 3-hourly data by 3 prior to calling cumsum. Alternatively,
   %  interpolate the data returned by this function from 3-hour to 1-hour
   %  posting prior to calling cumsum and omit the multiplication by 3.
   %
   %  Note on dimension ordering:
   %
   %  CF conventions store the data with dimensions [T Z Y X] in row-major.
   %  Matlab reads in reverse order: [X Y Z T]. Thus X is along the first
   %  dimension, Y the second. This function transposes the first and second
   %  dimension, so X is along the second dimension (across rows) and Y along
   %  the first dimension (down columns). Following this, the data is flipped
   %  along Y dimension because CF stores the data with Y increasing downward.
   %  These steps ensure the data is oriented with Y increasing northward, and
   %  X increasing eastward.
   %
   % See also:

   % Assume ncstart/count not provided
   partialRead = false;

   if nargin == 3
      % if 3 inputs, assume the third is the unit, to avoid ncinfo every read
      unit = varargin{1};

   elseif nargin == 4
      % if 4 inputs, assume they are ncstart,nccount
      ncstart = varargin{1};
      nccount = varargin{2};
      partialRead = true;

   elseif nargin == 5
      % if 5 inputs, assume they are ncstart,nccount,unit
      ncstart = varargin{1};
      nccount = varargin{2};
      unit = varargin{3};
      partialRead = true;
   end

   if nargin == 2 || nargin == 4
      % 2 inputs, need to find the unit
      fInfo = ncparse(filename);
      iVar = ismember(fInfo.Name, varname);
      unit = fInfo.units{iVar};
   end

   % Read the data and convert to double
   if partialRead
      dataGrid = double(squeeze(ncread(filename, varname, ncstart, nccount)));
   else
      dataGrid = double(squeeze(ncread(filename, varname)));
   end

   % Reshape the data. This works for 2d, 3d (daily), and 4d (hourly) data.
   % For 3-d data, it yields [x,y,t], where x and y are spatial coordinates and
   % t is time. For 4-d it also yields [x,y,t], but the original 3rd and 4th
   % dimensions are collapsed into one continuous time dimension. This works if
   % the 3rd and 4th dimension represent hours and days, e.g. if the data reads
   % in as [nx ny 24 365] the data is reshaped and returned as [ny nx 24*365].
   % However, this will not return the expected result if the 3rd dimension is
   % depth, not time.

   % Reshape the data to combine time dimensions for 4D data into a singular
   % time dimension.
   [r,c,h,d] = size(dataGrid);
   dataGrid = reshape(dataGrid, r, c, h * d);

   % Permute the spatial dimensions (swap X and Y) for conventional plotting
   % orientation, then flip the Y dimension to ensure Y increases upwards in the
   % resulting [Y, X, T] array, for conventional spatial data visualization.
   dataGrid = flipud(permute(dataGrid, [2 1 3]));

   % Unit conversions. Note, these were ported from MAR and RACMO, and many are
   % not applicable to MERRA.
   secondsPerHour = 3600.0;
   gramsPerKilogram = 1000.0;
   densityLiquidWater = 1000.0;
   milimetersPerMeter = 1000.0;
   freezingPointKelvins = 273.15;
   pascalsPerHectoPascal = 100.0;

   % convert non-standard units to standard units or preferred units
   if strcmp(unit,'mmWE/h')                        % convert to m/h
      dataGrid = dataGrid / milimetersPerMeter;
      unit = 'm/h';

   elseif strcmp(unit,'kg m-2 s-1')                % convert to m/h
      dataGrid = dataGrid * secondsPerHour / densityLiquidWater;
      unit = 'm/h';

   elseif strcmp(unit,'C')                         % convert to K
      dataGrid = dataGrid + freezingPointKelvins;
      unit = 'K';

   elseif strcmp(unit,'g/kg')                      % convert to kg/kg
      dataGrid = dataGrid / gramsPerKilogram;
      unit = 'kg/kg';

   elseif strcmp(unit,'hPa')                       % convert to Pa
      dataGrid = dataGrid * pascalsPerHectoPascal;
      unit = 'Pa';

   elseif strcmp(unit,'W m-2')
      unit = 'W/m2';

   elseif strcmp(unit,'m s-1')
      unit = 'm/s';

   elseif strcmp(unit,'kg kg-1')
      unit = 'kg/kg';

   elseif strcmp(unit,'kg m-2')                    % convert to m (eg swe)
      dataGrid = dataGrid / densityLiquidWater;
      unit = 'm';
   end

   % doing this here avoids having to do the conversions twice
   dataList = reshape(dataGrid, r*c, h*d);
end
