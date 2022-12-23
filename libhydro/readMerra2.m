function [dataGrid,dataList,Unit] = readMerra2(fileName,varName,varargin)
%READMERRA2 read merra2 .nc file
% 
%  [dataGrid,dataList,Unit] = readMerra2(fileName,varName)
%  [dataGrid,dataList,Unit] = readMerra2(fileName,varName,Unit)
%  [dataGrid,dataList,Unit] = readMerra2(fileName,varName,ncstart,nccount)
%  [dataGrid,dataList,Unit] = readMerra2(fileName,varName,Unit,ncstart,nccount)
% 
% 
% INPUTS
%   fileName    = full path to .nc file
%   varName     = string of varialbe name to read

% OUTPUTS
%   dataGrid    =


% NOTE: this assumes merra is interpolated to hourly, either before or
% after this function. It multiplies the incoming kg/m2/s by 3600 s/hr and
% divides by 1000 kg/m3 to get m/hr. If the data is interpolated to hourly,
% then cumsum will yield the correct amount. If it is NOT interpolated to
% hourly, then it would need to be multiplied by 3. but I interpolate
% hourly to standardize across models. Also, the Racmo data provided has
% units W/m2 or kg/m2/s, so the switch cases below are just for future
% reference in case I can extend this, and come from teh readMar function
% b/c MAR provided many more variables.

% assume ncstart/count not provided
partialRead = false;

% if 3 inputs, assume the third is the Unit, to avoid ncinfo every read
if nargin == 3
   Unit     = varargin{1};

   % if 4 inputs, assume they are ncstart,nccount
elseif nargin == 4
   ncstart     = varargin{1};
   nccount     = varargin{2};
   partialRead = true;

   % if 5 inputs, assume they are Unit,ncstart,nccount
elseif nargin == 5
   Unit        = varargin{1};
   ncstart     = varargin{2};
   nccount     = varargin{3};
   partialRead = true;

else
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
[r,c,h,d]   =   size(dataGrid);
dataGrid    =   reshape(dataGrid,r,c,h*d);
dataGrid    =   flipud(permute(dataGrid,[2 1 3]));


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
dataList  =   reshape(dataGrid,r*c,h*d);


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

