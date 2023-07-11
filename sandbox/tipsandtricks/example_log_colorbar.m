clean

save_figs   = false;

% this tests using logged data in a mapstruct and getting the colorbar
% right. there are three things to control: 1) the data, 2) the min/max
% values passed to the makesymbolspec, and 3) the min/max values passed to
% caxis

% if the data is logged, then the min/max values passed to makesymbolspec
% also need to be logged, so the colorscale matches the range in the
% plotted data, and the min/max values passed to caxis also need to be
% logged, but the values of the tickmarks need to be exponentiated. it
% might look correct to pass non-logged min/max values to caxis, but I am
% nearly certain the mapping is not technically correct (but the chances
% that anyone will notice is very low)


%% set paths

path.data   = '/Users/coop558/myprojects/e3sm/sag/output/';
path.slopes = setpath('INTERFACE/data/hillsloper/sag_basin/');
path.gis    = '/Users/coop558/mydata/e3sm/sag/hillsloper/IFSAR_hillslopes/';
path.save   = '/Users/coop558/Dropbox/CODE/MATLAB/INTERFACE/figs/mosart/';
run         = 'test.sag.54ef8b8.2021-04-15-103255';

%% read in the hillsloper data

load([path.slopes 'mosart_hillslopes']);

%% read in the mosart data

var     = 'RIVER_DISCHARGE_OVER_LAND_LIQ';
f       = [path.data run '/mat/data']; load(f);
nmonths = length(data);
ncells  = length(data(1).lon);
IDout   = find(isnan([newlinks.ds_link_ID])); % 2334 = outlet

%% pull out the discarge and add the outlet discharge

for i = 1:nmonths
    D(i,:)      = [data(i).(var)];
    D(i,IDout)  = data(i).RIVER_DISCHARGE_TO_OCEAN_LIQ(IDout);
end

%% take a single month

D       = D(8,:);
logD    = log(D);
for i = 1:length(newlinks)  % add the data to mstruct so symbolspec works
    newlinks(i).D = D(i);
    newlinks(i).logD = logD(i);
end

% plot
h1      = plotQlinks(newlinks);
h2      = plotQlinks(newlinks,'log');

% h1      = plotQslopes(newslopes);
% h2      = plotQlinks(newslopes,'log');

%==========================================================================
% test to figure out the right way to plot

minD        = min(D(:));
maxD        = max(D(:));
minlogD     = min(logD(:));
maxlogD     = max(logD(:));
cmap        = parula(numel(D));
Dspec       = makesymbolspec('Line',{'D',[minD maxD],'Color',cmap});
Dspeclog    = makesymbolspec('Line',{'logD',[minlogD maxlogD],'Color',cmap});
Dspeclog2   = makesymbolspec('Line',{'logD',[minD maxD],'Color',cmap});

% there are five possibilities, 

% 1. no log data, no log spec lims, no log clims, works as expected
figure; mapshow(newlinks,'SymbolSpec',Dspec); 
caxis([minD maxD]); colorbar;

% 2. log data, log spec lims, no log clims, plots as expected, colorbar normal
figure; mapshow(newlinks,'SymbolSpec',Dspeclog); 
caxis([minD maxD]); colorbar;

% 3. log data, log spec lims, log clims, plots as expected, colorbar log
figure; mapshow(newlinks,'SymbolSpec',Dspeclog); 
caxis([minlogD maxlogD]); colorbar;

% 4. log data, no log spec lims, no log clims, doesn't work
figure; mapshow(newlinks,'SymbolSpec',Dspeclog2); 
caxis([minD maxD]); colorbar;

% 5. log data, no log spec lims, no log clims, doesn't work
figure; mapshow(newlinks,'SymbolSpec',Dspeclog2); 
caxis([minlogD maxlogD]); colorbar;