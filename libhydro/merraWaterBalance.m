function Merra = merraWaterBalance(basinname,varargin)
   %MERRAWATERBALANCE Compute MERRA2 water balance for basin.
   %
   %  Merra = merraWaterBalance(basinname) returns timetable Merra with water
   %  balance components as columns and rows as timesteps for the entire period
   %  of record (1981-2020).
   %
   %  Merra = merraWaterBalance(basinname,'t1',t1,'t2',t2) returns timetable
   %  Merra with water balance components as columns and rows as timesteps for
   %  the period of time bounded by t1 and t2.
   %
   %  Merra = merraWaterBalance(___,) (placeholder for future options)
   %
   % Matt Cooper, 20-Feb-2022, mgcooper@github.com
   %
   % See also merraSnowCorrection, annualdMdt, graceSnowCorrect

   import baseflow.loadbasins

   % parse inputs
   [basinname, t1, t2] = parseinputs(basinname, mfilename, varargin{:});

   % data are available from 1/1980 to 1/2022
   try
      load('merrafilelist.mat','filelist');
   catch e
      throwAsCaller(e)
   end

   cmyr = 24.*365.25.*100;           % to convert from m/h to cm/yr
   unit = 'kg m-2 s-1';              % the native merra2 unit see info

   % find the files corresponding to requested t1:t2 time period
   if ~isnat(t1)
      fnames = tocolumn({filelist.name});
      fdates = NaT(size(fnames));
      for n = 1:numel(fnames)
         fparts = strsplit(fnames{n},'.');
         fdates(n) = datetime(fparts{3},'InputFormat','yyyyMM');
      end
      idx = isbetween(fdates,t1,t2);
      filelist = filelist(idx);
   else
      d1 = filelist(1).name(28:33);
      d2 = filelist(end).name(28:33);
      t1 = datetime(str2double(d1(1:4)),str2double(d1(5:6)),1);
      t2 = datetime(str2double(d2(1:4)),str2double(d2(5:6)),1);
   end

   % load the basin polygon in equal-area projection to get area in m2
   [~,~,poly] = loadbasins(basinname,'current','projection','ease');
   aream2 = poly.area;
   [~,~,poly] = loadbasins(basinname,'current','projection','geo');

   % Get the list of variables in the nc files
   info = ncinfo(fullfile(filelist(1).folder, filelist(1).name));
   vars = {info.Variables.Name};

   % Read the lat, lon, and one data grid to initialize things
   lon = readMerra2(fullfile(filelist(1).folder, filelist(1).name), 'lon');
   lat = readMerra2(fullfile(filelist(1).folder, filelist(1).name), 'lat');
   [LON, LAT] = meshgrid(lon, lat);
   LAT = flipud(LAT);

   % Get the size of the output data (rows, cols, and pages)
   [r,c] = size(LAT);
   p = length(filelist); % p = num months

   % Initialize data
   P = nan(r,c,p);
   E = nan(r,c,p);
   R = nan(r,c,p);
   S = nan(r,c,p);
   BF = nan(r,c,p);
   SW = nan(r,c,p);
   TW = nan(r,c,p);

   for n = 1:p

      % % to use this, need a way to update the assimilation stream (100 below)
      % yyyy = num2str(year(t1+calmonths(n-1)));
      % mm = num2str(month(t1+calmonths(n-1)));
      % if numel(mm) == 1
      %    mm = strcat('0',mm);
      % end
      % yyyymm = strcat(yyyy,mm);
      % fname = [pathdata 'MERRA2_100.tavgM_2d_lnd_Nx.' yyyymm '.nc4.nc4'];

      filename = fullfile(filelist(n).folder, filelist(n).name);

      P(:,:,n) = readMerra2(filename, 'PRECTOTLAND', unit);
      E(:,:,n) = readMerra2(filename, 'EVLAND', unit);
      R(:,:,n) = readMerra2(filename, 'RUNOFF', unit);
      S(:,:,n) = readMerra2(filename, 'WCHANGE', unit);
      BF(:,:,n) = readMerra2(filename, 'BASEFLOW', unit);

      % these two have units kg/m2
      SW(:,:,n) = readMerra2(filename, 'SNOMAS', 'kg m-2');
      TW(:,:,n) = readMerra2(filename, 'TWLAND', 'kg m-2');

   end % data come out in units m/hr or m

   % clip the merra2 data to the basin

   % read in the kuparuk basin and find the points in the poly
   Mask = pointsInPoly(LON,LAT,poly,'buffer',0.10,'makeplot',true);
   inpolyb = Mask.inpolyb(:);

   % reshape the data to lists and extract data for the catchment
   [r,c,p] = size(P);
   P = reshape(P,r*c,p);   P = P(inpolyb,:);
   E = reshape(E,r*c,p);   E = E(inpolyb,:);
   R = reshape(R,r*c,p);   R = R(inpolyb,:);
   S = reshape(S,r*c,p);   S = S(inpolyb,:);
   BF = reshape(BF,r*c,p);  BF = BF(inpolyb,:);
   SW = reshape(SW,r*c,p);  SW = SW(inpolyb,:);
   TW = reshape(TW,r*c,p);  TW = TW(inpolyb,:);

   % in.lat = LAT(inpolyb);
   % in.lon = LON(inpolyb);
   % in.idx = inpolyb;
   % in.P = P;
   % save('testdata', 'in');

   % compute the balance
   % B1 = P-E-R;   % this = S, so I commented it out and renamed B2 to B
   % B = P-E-R-S; % in theory this should = -Thaw Rate

   % Get Merra R in m3/s for comparison with gage flow, and the rest in cm/year
   Rm3s = tocolumn(cmd2cms(mean(R, 1, 'omitnan').*24.*aream2));    % m3/day -> m3/s
   P = tocolumn(cmyr.*mean(P, 1, 'omitnan'));                     % m/hr -> cm/yr
   E = tocolumn(cmyr.*mean(E, 1, 'omitnan'));                     % m/hr -> cm/yr
   R = tocolumn(cmyr.*mean(R, 1, 'omitnan'));                     % m/hr -> cm/yr
   S = tocolumn(cmyr.*mean(S, 1, 'omitnan'));                     % m/hr -> cm/yr
   BF = tocolumn(cmyr.*mean(BF, 1, 'omitnan'));                    % m/hr -> cm/yr
   SW = tocolumn(100.*mean(SW, 1, 'omitnan'));                   % m    -> cm
   TW = tocolumn(100.*mean(TW, 1, 'omitnan'));                   % m    -> cm
   %  B = tocolumn(cf.*mean(B,1));                     % m/hr -> cm/yr

   clear Mask inpolyb data

   % synchronize all the data

   % build a merra calendar and timetable, then synchronize all the data
   Time = tocolumn(t1:calmonths(1):t2);
   Merra = timetable(Rm3s,P,E,R,S,BF,SW,TW,'RowTimes',Time);
   Merra = settableunits(Merra,{'m3/s','cm/y','cm/y','cm/y','cm/y','cm/y','cm','cm'});
end

%%
function [basinname, t1, t2] = parseinputs(basinname, funcname, varargin)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('basinname', @ischar);
   parser.addParameter('t1', NaT, @(x) isdatetime(x) | isnumeric(x));
   parser.addParameter('t2', NaT, @(x) isdatetime(x) | isnumeric(x));
   parser.parse(basinname, varargin{:});

   t1 = parser.Results.t1;
   t2 = parser.Results.t2;
   if isnumeric(t1)
      t1 = datetime(t1,'ConvertFrom','datenum');
      t2 = datetime(t2,'ConvertFrom','datenum');
   end
end
