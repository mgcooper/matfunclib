function [dataGrid,dataList,Unit] = readMerra2(fileName,varName,varargin)
   %READMERRA2 read data from merra2 .nc file
   %
   % Syntax
   %
   %  [dataGrid,dataList] = readMerra2(fileName,varName)
   %  [dataGrid,dataList] = readMerra2(fileName,varName,ncstart,nccount)
   %  [dataGrid,dataList,Unit] = readMerra2(fileName,varName,Unit)
   %  [dataGrid,dataList,Unit] = readMerra2(fileName,varName,ncstart,nccount,Unit)
   %
   % Description
   %
   %  [dataGrid,dataList] = readMerra2(fileName,varName) reads the data from
   %  variable `varName` contained in the MERRA2 .nc file specified by
   %  `fileName`. `dataGrid` contains the data reshaped to column-major format
   %  as a data grid (matrix). `dataList` contains the data reshaped to
   %  list-format.
   %
   %  [dataGrid,dataList] = readMerra2(fileName,varName,ncstart,nccount) reads
   %  data beginning at the location of each dimension specified in `start`. The
   %  `count` argument specifies the number of elements to read along each
   %  dimension.
   %
   %  [dataGrid,dataList,Unit] = readMerra2(___,Unit) uses the unit specified by
   %  input argument `Unit` to convert the variable to a pre-defined standard
   %  output `Unit`. For example, mass fluxes stored in Merra2 files in units
   %  kg/m2/s are converted to m/hr. Temperature data stored in units Celsius
   %  are converted to Kelvins. If the provided value for Unit is not
   %  recognized, the variable is not converted. Use with either of the two
   %  prior syntaxes.
   %
   % REQUIRED INPUTS
   %     fileName - full path to .nc file
   %     varName  - character array or cellstr of variabe name to read
   %
   % OPTIONAL INPUTS
   %     ncstart  - numeric vector of positive integers representing the
   %                starting location along each data dimension.
   %     nccount  - numeric vector of positive integers representing the number
   %                of elements to read along each data dimension.
   %     Unit     - character array specifying the unit of the variable to read
   %
   % OUTPUTS
   %   dataGrid   - the data stored as a spatial grid in column-major format
   %   dataList   - the data stored as a spatial list
   %   Unit       - the unit of the data in dataGrid and/or dataList
   %
   % NOTE: merra2 data is posted at 3-hour time intervals. Merra 2 variables that
   % represent mass fluxes (such as runoff) are converted by this function from
   % kg/m2/s to m/h, meaning they represent 3-hour averages. To accumulate fluxes,
   % multiply the 3-hourly data by 3 prior to calling cumsum. Alternatively,
   % interpolate the data returned by this function from 3-hour to 1-hour posting
   % prior to calling cumsum and omit the multiplication by 3.
   %
   % See also: 

   % assume ncstart/count not provided
   partialRead = false;

   if nargin == 3
      % if 3 inputs, assume the third is the Unit, to avoid ncinfo every read
      Unit = varargin{1};

   elseif nargin == 4
      % if 4 inputs, assume they are ncstart,nccount
      ncstart     = varargin{1};
      nccount     = varargin{2};
      partialRead = true;

   elseif nargin == 5
      % if 5 inputs, assume they are ncstart,nccount,Unit
      ncstart     = varargin{1};
      nccount     = varargin{2};
      Unit        = varargin{3};
      partialRead = true;
   end

   if nargin == 2 || nargin == 4
      % 2 inputs, need to find the unit
      fInfo   = ncparse(fileName);
      iVar    = ismember(fInfo.Name,varName);
      Unit    = fInfo.Units{iVar};
   end


   % read the data and convert to double
   if partialRead
      dataGrid = double(squeeze(ncread(fileName,varName,ncstart,nccount)));
   else
      dataGrid = double(squeeze(ncread(fileName,varName)));
   end

   % reshape the data. note, this works for 2d, 3d (daily), and 4d (hourly)
   % data, even though it may not seem like it would. For 3-d data, it
   % preserves all dimensions, so you get [x,y,t], where x and y are spatial
   % coordinates and t is time. For 4-d you also get [x,y,t], but it is
   % assumed that the original 3rd and 4th dimensions were both time, such as
   % hours and days, so you get a collapsed time dimensions.
   [r,c,h,d] = size(dataGrid);
   dataGrid = reshape(dataGrid,r,c,h*d);
   dataGrid = flipud(permute(dataGrid,[2 1 3]));

   % NOTE: racmo and merra are kg/m2/s posted every three hours, but don't
   % multipy by 3*3600/1000 unless the data is kept at three hour posting. If
   % the data is interpolated to hourly, then multiply by 3600/1000, so it's
   % m/hr posted every hour.

   densityLiquidWater      = 1000.0;
   milimetersPerMeter      = 1000.0;
   secondsPerHour          = 3600.0;
   freezingPointKelvins    = 273.15;
   gramsPerKilogram        = 1000.0;
   pascalsPerHectoPascal   = 100.0;

   % convert non-standard units to standard units or preferred units
   if strcmp(Unit,'mmWE/h')                        % convert to m/h
      dataGrid =   dataGrid./milimetersPerMeter;
      Unit     =   'm/h';
   elseif strcmp(Unit,'kg m-2 s-1')                % convert to m/h
      dataGrid =   dataGrid.*(secondsPerHour/densityLiquidWater);
      Unit     =   'm/h';
   elseif strcmp(Unit,'C')                         % convert to K
      dataGrid =   dataGrid+freezingPointKelvins;
      Unit     =   'K';
   elseif strcmp(Unit,'g/kg')                      % convert to kg/kg
      dataGrid =   dataGrid./gramsPerKilogram;
      Unit     =   'kg/kg';
   elseif strcmp(Unit,'hPa')                       % convert to Pa
      dataGrid =   dataGrid.*pascalsPerHectoPascal;
      Unit     =   'Pa';
   elseif strcmp(Unit,'W m-2')
      Unit     =   'W/m2';
   elseif strcmp(Unit,'m s-1')
      Unit     =   'm/s';
   elseif strcmp(Unit,'kg kg-1')
      Unit     =   'm/s';
   elseif strcmp(Unit,'kg m-2')                    % convert to m (eg swe)
      dataGrid =   dataGrid./densityLiquidWater;
      Unit     =   'm';
   end

   % doing this here avoids having to do the conversions twice
   dataList = reshape(dataGrid,r*c,h*d);

   % % this was what originally would have come after getting the Unit, so if
   % above method from readMar doesn't work, revert to this
   %     switch ndims(dataGrid)
   %         case 2
   %             dataGrid    = flipud(permute(dataGrid,[2 1]));
   %             dataList  = reshape(dataGrid,numel(dataGrid),1);
   %         case 3
   %             dataGrid    = flipud(permute(dataGrid,[2 1 3]));
   %             dataList  = reshape(dataGrid,size(dataGrid,1)*size(dataGrid,2),size(dataGrid,3));
   %     end
end
