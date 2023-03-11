function Merra = merraWaterBalance(basinname,varargin)
%MERRAWATERBALANCE compute MERRA2 water balance for basin.
%
%  Merra = merraWaterBalance(basinname) returns timetable Merra with water
%  balance components as columns and rows as timesteps for the entire period of
%  record (1981-2020).
%
%  Merra = merraWaterBalance(basinname,'t1',t1,'t2',t2) returns timetable Merra
%  with water balance components as columns and rows as timesteps for the period
%  of time bounded by t1 and t2.
%
%  Merra = merraWaterBalance(___,) (placeholder for future options)
%
% Matt Cooper, 20-Feb-2022, mgcooper@github.com
%
% See also merraSnowCorrection, annualdMdt, graceSnowCorrect

%-------------------------------------------------------------------------------
p=magicParser;
p.FunctionName=mfilename;
p.addRequired('basinname',@(x)ischar(x));
p.addParameter('t1',NaT,@(x) isdatetime(x)|isnumeric(x));
p.addParameter('t2',NaT,@(x) isdatetime(x)|isnumeric(x));
p.parseMagically('caller');

if isnumeric(t1) %#ok<*NODEF>
   t1 = datetime(t1,'ConvertFrom','datenum');
   t2 = datetime(t2,'ConvertFrom','datenum');
end
%-------------------------------------------------------------------------------

% data are available from 1/1980 to 1/2022
load('merrafilelist.mat','filelist');

% find the files corresponding to requested t1:t2 time period
if ~isnat(t1)
   fnames   =  tocol({filelist.name});
   fdates   =  NaT(size(fnames));
   for n = 1:numel(fnames)
      fparts      =  strsplit(fnames{n},'.');
      fdates(n)   =  datetime(fparts{3},'InputFormat','yyyyMM');
   end
   idx      = isbetween(fdates,t1,t2);
   filelist = filelist(idx);
else
   d1    = filelist(1).name(28:33);
   d2    = filelist(end).name(28:33);
   t1    = datetime(str2double(d1(1:4)),str2double(d1(5:6)),1);
   t2    = datetime(str2double(d2(1:4)),str2double(d2(5:6)),1);
end

% load the basin polygon in equal-area projection to get area in m2
[~,~,poly]  =  bfra.loadbounds(basinname,'current','projection','ease');
aream2      =  poly.area;
[~,~,poly]  =  bfra.loadbounds(basinname,'current','projection','geo');

cf          =  24.*365.25.*100;           % to convert from m/h to cm/yr
unit        =  'kg m-2 s-1';              % the native merra2 unit see info

pathdata    =  [filelist(1).folder '/'];
info        =  ncinfo([pathdata filelist(1).name]);
vars        =  {info.Variables.Name};
data        =  ncreaddata([pathdata filelist(1).name],vars);
[LON,LAT]   =  meshgrid(data.lon,data.lat);
LAT         =  flipud(LAT);

% prep for reading in all files
[r,c]       =  size(LAT);
nm          =  length(filelist); % nm = num months
P           =  nan(r,c,nm); E=nan(r,c,nm); R=nan(r,c,nm); S=nan(r,c,nm);
BF          =  nan(r,c,nm); SW = nan(r,c,nm); TW = nan(r,c,nm);

for n = 1:nm

   % % to use this, need a way to update the assimilation stream (100 below)
   %       yyyy     =  num2str(year(t1+calmonths(n-1)));
   %       mm       =  num2str(month(t1+calmonths(n-1)));
   %       if numel(mm) == 1
   %          mm    =  strcat('0',mm);
   %       end
   %       yyyymm   =  strcat(yyyy,mm);
   %       fname    =  [pathdata 'MERRA2_100.tavgM_2d_lnd_Nx.' yyyymm '.nc4.nc4'];

   fname    =  [pathdata filelist(n).name];

   %       if contains(fname,newstreams)

   P(:,:,n)    =  readMerra2(fname,'PRECTOTLAND',unit);
   E(:,:,n)    =  readMerra2(fname,'EVLAND',unit);
   R(:,:,n)    =  readMerra2(fname,'RUNOFF',unit);
   S(:,:,n)    =  readMerra2(fname,'WCHANGE',unit);
   BF(:,:,n)   =  readMerra2(fname,'BASEFLOW',unit);

   % these two have units kg/m2
   SW(:,:,n)   =  readMerra2(fname,'SNOMAS','kg m-2');
   TW(:,:,n)   =  readMerra2(fname,'TWLAND','kg m-2');

end % data come out in units m/hr or m

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 	clip the merra2 data to the basin
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% read in the kuparuk basin and find the points in the poly
Mask     =  pointsInPoly(LON,LAT,poly,'buffer',0.10,'makeplot',true);
inpolyb  =  Mask.inpolyb(:);

% reshape the data to lists and extract data for the catchment
[r,c,nm] =  size(P);
P        =  reshape(P,r*c,nm);   P  = P(inpolyb,:);
E        =  reshape(E,r*c,nm);   E  = E(inpolyb,:);
R        =  reshape(R,r*c,nm);   R  = R(inpolyb,:);
S        =  reshape(S,r*c,nm);   S  = S(inpolyb,:);
BF       =  reshape(BF,r*c,nm);  BF = BF(inpolyb,:);
SW       =  reshape(SW,r*c,nm);  SW = SW(inpolyb,:);
TW       =  reshape(TW,r*c,nm);  TW = TW(inpolyb,:);

% compute the balance
% B1     =  P-E-R;   % this = S, so I commented it out and renamed B2 to B
% B      =  P-E-R-S; % in theory this should = -Thaw Rate

% Get Merra R in m3/s for comparison with gage flow, and the rest in cm/year
Rm3s     =  tocol(cmd2cms(mean(R,1).*24.*aream2));    % m3/day -> m3/s
P        =  tocol(cf.*mean(P,1));                     % m/hr -> cm/yr
E        =  tocol(cf.*mean(E,1));                     % m/hr -> cm/yr
R        =  tocol(cf.*mean(R,1));                     % m/hr -> cm/yr
S        =  tocol(cf.*mean(S,1));                     % m/hr -> cm/yr
BF       =  tocol(cf.*mean(BF,1));                    % m/hr -> cm/yr
SW       =  tocol(100.*mean(SW,1));                   % m    -> cm
TW       =  tocol(100.*mean(TW,1));                   % m    -> cm
%  B        =  tocol(cf.*mean(B,1));                     % m/hr -> cm/yr

clear Mask inpolyb data

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%    synchronize all the data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% build a merra calendar and timetable, then synchronize all the data
Time  = tocol(t1:calmonths(1):t2);
Merra = timetable(Rm3s,P,E,R,S,BF,SW,TW,'RowTimes',Time);
Merra = settableunits(Merra,{'m3/s','cm/y','cm/y','cm/y','cm/y','cm/y','cm','cm'});
