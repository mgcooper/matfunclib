function [Merra, LAT, LON] = merraWaterBalance(kwargs)
   %MERRAWATERBALANCE Compute MERRA2 water balance for basin.
   %
   %  Merra = merraWaterBalance() returns a timetable with Merra-2 Northern
   %  Hemisphere-average water balance components for the entire period of
   %  record (1981-2020) on a monthly timestep.
   %
   %  Merra = merraWaterBalance(poly=poly, t1=t1, t2=t2) returns timetable
   %  with Merra-2 water balance components averaged over the spatial region
   %  enclosed by POLY for the period of time bounded by t1 and t2.
   %
   % Matt Cooper, 20-Feb-2022, mgcooper@github.com
   %
   % See also merraSnowCorrection, annualdMdt, graceSnowCorrect

   arguments
      kwargs.poly (:, :) {mustBePolygon} = polyshape.empty()
      kwargs.t1 (1, :) {mustBeDateLike} = datetime.empty()
      kwargs.t2 (1, :) {mustBeDateLike} = datetime.empty()
      kwargs.filelist (:, :) {mustBeA(kwargs.filelist, 'struct')} = struct.empty()
      kwargs.clipToPoly (1, 1) logical = true
      kwargs.polybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.xpolybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.ypolybuffer (1, 1) {mustBeNumeric} = 0
      kwargs.xcellbuffer (1, 1) {mustBeInteger} = 0
      kwargs.ycellbuffer (1, 1) {mustBeInteger} = 0
      kwargs.makeplot (1, 1) logical = false
      kwargs.debug (1, 1) logical = false
   end
   [poly, t1, t2, filelist] = deal(kwargs.poly, kwargs.t1, kwargs.t2, ...
      kwargs.filelist);

   if all(isempty(poly)) || kwargs.debug
      poly = createDefaultPoly(); % Northern Hemisphere
   else
      assert(isa(poly, 'polyshape')) % TODO: convert x,y to polyshape
   end
   xpoly = poly.Vertices(:, 1);
   ypoly = poly.Vertices(:, 2);

   if islatlon(ypoly, xpoly)
      ellips = referenceEllipsoid('wgs84', 'meter');
      aream2 = areaint(ypoly, xpoly, ellips);

      % To use equal-area or to verify areaint:
      % proj = loadprojcrs('ease-north');
      % [xease, yease] = projfwd(proj, ypoly, xpoly);
      % aream2 = polyarea(xease, yease);
   else
      aream2 = area(poly);
   end

   % Merra2 data are available from 1/1980 to 1/2022
   if isempty(filelist)
      try
         load('merrafilelist.mat', 'filelist');
      catch e
         throwAsCaller(e)
      end
   end

   % To convert from m/h to cm/yr and to pass the unit to readMerra2
   CMPERYEAR = 24 * 365.25 * 100;
   FLUX_UNIT = 'kg m-2 s-1';
   MASS_UNIT = 'kg m-2';

   % Create a calendar and file list for the requested time period.
   [Time, filelist] = parseTimePeriod(t1, t2, filelist);

   % Get the list of variables in the nc files
   fileinfo = ncinfo(fullfile(filelist(1).folder, filelist(1).name));
   varnames = {fileinfo.Variables.Name};

   % Read the lat, lon, and one data grid to initialize outputs
   filename = fullfile(filelist(1).folder, filelist(1).name);
   lon = ncread(filename, 'lon');
   lat = ncread(filename, 'lat');

   % Note: start, count are oriented in ndgrid format, like the underlying data.
   [start, count] = ncrowcol('RUNOFF', lon, lat, xpoly, ypoly, ...
      ncinfo=fileinfo, ...
      polybuffer=kwargs.polybuffer, ...
      xpolybuffer=kwargs.xpolybuffer, ...
      ypolybuffer=kwargs.ypolybuffer, ...
      xcellbuffer=kwargs.xcellbuffer, ...
      ycellbuffer=kwargs.ycellbuffer);

   if kwargs.makeplot
      makeTestPlot(filename, start, count, poly, 'plotraster')
      title('cells found by ncrowcol')
   end

   % Get the size of the output data (rows, cols, and pages)
   c = count(1);
   r = count(2);
   p = length(filelist); % p = num months

   % Read the data. The data are returned in units m/hr or m.
   [P, E, R, S, BF, SW, TW] = deal(nan(r * c, p)); % Initialize outputs
   for n = 1:p
      filename = fullfile(filelist(n).folder, filelist(n).name);
      [~, P(:,n)] = readMerra2(filename, 'PRECTOTLAND', start, count, FLUX_UNIT);
      [~, E(:,n)] = readMerra2(filename, 'EVLAND', start, count, FLUX_UNIT);
      [~, R(:,n)] = readMerra2(filename, 'RUNOFF', start, count, FLUX_UNIT);
      [~, S(:,n)] = readMerra2(filename, 'WCHANGE', start, count, FLUX_UNIT);
      [~, BF(:,n)] = readMerra2(filename, 'BASEFLOW', start, count, FLUX_UNIT);
      [~, SW(:,n)] = readMerra2(filename, 'SNOMAS', start, count, MASS_UNIT);
      [~, TW(:,n)] = readMerra2(filename, 'TWLAND', start, count, MASS_UNIT);
   end

   % Create oriented lat/lon grids for the oriented data returned by readMerra2
   lon = readMerra2(filename, 'lon', start(1), count(1));
   lat = readMerra2(filename, 'lat', start(2), count(2));
   [LON, LAT] = meshgrid(lon, lat);
   LAT = flipud(LAT);

   assertEqual([r, c], size(LAT));

   % Clip out the points within the basin, whereas ncrowcol returns a
   % regular grid extending to the edges of the basin bounding box.
   if kwargs.clipToPoly
      Mask = pointsInPoly(LON, LAT, poly, ...
         buffer=kwargs.polybuffer, ...
         bufferbox=false);
      if kwargs.makeplot
         scatter(LON(Mask.inpolyb(:)), LAT(Mask.inpolyb(:)), 'g', 'filled')
         title('')
         legend('poly', 'cells found by ncrowcol', 'cells clipped to poly', ...
            'Location', 'northoutside', 'Orientation', 'horizontal', ...
            'numcolumns', 3)
      end
      inpolyb = Mask.inpolyb(:);
   else
      inpolyb = true(size(P, 1), 1);
   end

   % Compute catchment-mean values (down columns = averaging over grid cells)
   P = mean(P(inpolyb, :), 1, 'omitnan');
   E = mean(E(inpolyb, :), 1, 'omitnan');
   R = mean(R(inpolyb, :), 1, 'omitnan');
   S = mean(S(inpolyb, :), 1, 'omitnan');
   BF = mean(BF(inpolyb, :), 1, 'omitnan');
   SW = mean(SW(inpolyb, :), 1, 'omitnan');
   TW = mean(TW(inpolyb, :), 1, 'omitnan');

   % Compute Merra runoff in m3/s for comparison with gaged flow.
   Rcms = tocolumn(cmd2cms(R * 24 * aream2));   % m3/day -> m3/s

   % Compute the water balance components in cm/year
   P = tocolumn(CMPERYEAR * P);                 % m/hr -> cm/yr
   E = tocolumn(CMPERYEAR * E);                 % m/hr -> cm/yr
   R = tocolumn(CMPERYEAR * R);                 % m/hr -> cm/yr
   S = tocolumn(CMPERYEAR * S);                 % m/hr -> cm/yr
   BF = tocolumn(CMPERYEAR * BF);               % m/hr -> cm/yr
   SW = tocolumn(100 * SW);                     % m    -> cm
   TW = tocolumn(100 * TW);                     % m    -> cm

   % Synchronize the data.
   Merra = timetable(Rcms, P, E, R, S, BF, SW, TW, 'RowTimes', Time);
   Merra = settableunits(Merra, ...
      {'m3 s-1','cm yr-1','cm yr-1','cm yr-1','cm yr-1','cm yr-1','cm','cm'});
end

function [Time, filelist] = parseTimePeriod(t1, t2, filelist)

   % Convert datenums or datestrs to datetime
   if ~isdatetime(t1)
      t1 = todatetime(t1);
   end
   if ~isdatetime(t1)
      t2 = todatetime(t2);
   end

   % If no dates were specified, use the full list
   if all(isnat(t1)) || all(isempty(t1))
      d1 = filelist(1).name(28:33);
      d2 = filelist(end).name(28:33);
      t1 = datetime(str2double(d1(1:4)), str2double(d1(5:6)), 1);
      t2 = datetime(str2double(d2(1:4)), str2double(d2(5:6)), 1);
   end

   % Create a calendar for the requested time period
   Time = tocolumn(t1:calmonths(1):t2);

   % Downselect the file list to the requested t1:t2 time period
   filenames = tocolumn({filelist.name});
   filedates = NaT(size(filenames));
   for n = 1:numel(filenames)
      fileparts__ = strsplit(filenames{n},'.');
      filedates(n) = datetime(fileparts__{3},'InputFormat','yyyyMM');
   end
   idx = isbetween(filedates,t1,t2);
   filelist = filelist(idx);
end

function [poly, xpoly, ypoly] = createDefaultPoly()
   % Define coordinates for the bounding box around North America
   lat_min = 45;
   lat_max = 72;
   lon_min = -168;
   lon_max = -52;

   % Create vectors for the bounding box coordinates
   ypoly = [lat_min, lat_min, lat_max, lat_max, lat_min];
   xpoly = [lon_min, lon_max, lon_max, lon_min, lon_min];

   poly = polyshape(xpoly, ypoly);
end

function makeTestPlot(filename, start, count, poly, option)

   lon = readMerra2(filename, 'lon', start(1), count(1));
   lat = readMerra2(filename, 'lat', start(2), count(2));
   var = readMerra2(filename, 'RUNOFF', start, count);

   % Create a regular grid to plot the cell nodes
   [LON, LAT] = meshgrid(lon, lat);
   LAT = flipud(LAT);

   % Plot the polygon and enclosed grid cells
   figure;
   hold on;

   % Plot the grid cells
   switch option
      case 'plotraster'
         plotraster(var, lon, lat);
      case 'rastersurf'
         Ref = rasterref(lon, lat);
         rastersurf(var, Ref)
   end
   % Plot the polygon
   plot(poly)

   % Plot the cell centroids
   scatter(LON(:), LAT(:), 'filled')

   % Add labels
   xlabel('Longitude');
   ylabel('Latitude');

   % This is not necessary but further confirms things are correct
   % figure; hold on
   % scatter(LON(:), LAT(:), 40, var(:), 'filled')
   % plot(poly)
end
