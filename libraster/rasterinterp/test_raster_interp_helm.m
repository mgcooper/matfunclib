clean

%%

% To speed up rasterinterp, I could first resize the mask to 1 km posting,
% then rasterinterp the Helm dem to the resized mask

%%
geo_data            =   1;
map_data            =   0;
save_data           =   0;
plot_data           =   0;
save_figs           =   0;
%% test Chad Green's suggestion for subsetting with raster

% I want to clip the dem to the mask extent and then resize the dem to the
% mask and then use the mask

delim               =   '/';
path.data           =   ['/Users/MattCooper/Google UCLA/ArcGIS/Greenland/' ...
                        'CryoSat/helm_dem/'];
path.mask           =   ['/Users/MattCooper/Google UCLA/ArcGIS/Greenland/' ...
                        'Greenland/GIMP/IceMask/tif/'];
path.save           =   ['/Users/MattCooper/Dropbox/CODE/MATLAB/' ...
                            'myFunctions/raster/rasterinterp/figs/'];
%% read in the data

% set path to each file
if geo_data == 1
    fdata           =   [path.data 'geo' delim 'DEM_GRE_CS_20130826.tif'];
    fmask           =   [path.mask 'GimpIceMask_90m_geo.tif'];
    [Zdata,Rdata]   =   geotiffread(fdata);
    [Zmask,Rmask]   =   geotiffread(fmask);
    Zmask           =   single(Zmask);
    naninds         =   Zdata==min(Zdata(:));
    Zdata(naninds)  =   nan;
    naninds         =   Zmask==32767;
    Zmask(naninds)  =   0;
    sf              =   Rmask.CellExtentInLongitude/Rdata.CellExtentInLatitude;
    [Zmask,Rmask]   =   georesize(Zmask,Rmask,sf,'nearest');
end

if map_data == 1
    fdata           =   [path.data 'ups' delim 'DEM_GRE_CS_20130826.tif'];
    fmask           =   [path.mask 'GimpIceMask_90m.tif'];
    [Zdata,Rdata]   =   geotiffread(fdata);
    [Zmask,Rmask]   =   geotiffread(fmask);
    Zmask           =   single(Zmask);
    sf              =   Rmask.CellExtentInWorldX/Rdata.CellExtentInWorldY;
    [Zmask,Rmask]   =   mapresize(Zmask,Rmask,sf,'nearest');
end

% apply the rasterinterp function. default interpolation is bilinear
Znew                =   rasterinterp(Zdata,Rdata,Rmask);
Rnew                =   Rmask;

% round to nearest meter
Znew                =   roundn(Znew,0);

% apply the mask
Zmasked             =   Zmask.*Znew;

%%

if plot_data == 1 && map_data == 1
    
    figure
    mapshow(logical(Zmask),Rmask); ax1 = gca;
    title('Mask')
    ax1.XLim = Rmask.XWorldLimits;
    ax1.YLim = Rmask.YWorldLimits;
    
    figure
    mapshow(Zdata,Rdata,'DisplayType','surface'); ax2 = gca;
    colorbar
    title('Original');
    ax2.XLim = Rdata.XWorldLimits;
    ax2.YLim = Rdata.YWorldLimits;
    
    figure;
    mapshowsurface(Znew,Rnew,'DisplayType','surface'); ax3 = gca;
    title('Interpolated');
    colorbar
    ax3.XLim = Rnew.XWorldLimits;
    ax3.YLim = Rnew.YWorldLimits;
    
    figure;
    mapshow(Zmasked,Rnew,'DisplayType','surface'); ax4 = gca;
    title('Masked');
    colorbar
    ax4.XLim = Rnew.XWorldLimits;
    ax4.YLim = Rnew.YWorldLimits;
    
    figure;
    mapshow(Znew-Zmasked,Rnew,'DisplayType','surface'); ax5 = gca;
    title('Interpolated-Masked');
    colorbar
    ax5.XLim = Rnew.XWorldLimits;
    ax5.YLim = Rnew.YWorldLimits;
    
end

if plot_data == 1 && geo_data == 1
    
    figure
    geoshow(logical(Zmask),Rmask); ax1 = gca;
    title('Mask')
    ax1.XLim = Rmask.LongitudeLimits;
    ax1.YLim = Rmask.LatitudeLimits;
    
    figure
    geoshow(Zdata,Rdata,'DisplayType','surface'); ax2 = gca;
    colorbar
    title('Original');
    ax2.XLim = Rdata.LongitudeLimits;
    ax2.YLim = Rdata.LatitudeLimits;
    
    figure;
    geoshow(Znew,Rnew,'DisplayType','surface'); ax3 = gca;
    title('Interpolated');
    colorbar
    ax3.XLim = Rnew.LongitudeLimits;
    ax3.YLim = Rnew.LatitudeLimits;
    
    figure;
    geoshow(Zmasked,Rnew,'DisplayType','surface'); ax4 = gca;
    title('Masked');
    colorbar
    ax4.XLim = Rnew.LongitudeLimits;
    ax4.YLim = Rnew.LatitudeLimits;
    
    figure;
    geoshow(Znew-Zmasked,Rnew,'DisplayType','surface'); ax5 = gca;
    title('Interpolated-Masked');
    colorbar
    ax5.XLim = Rnew.LongitudeLimits;
    ax5.YLim = Rnew.LatitudeLimits;
end

%    
if save_figs == 1 && map_data == 1
    export_fig(ax1,[path.save 'map' delim 'mask.png'],'-r400');
    export_fig(ax2,[path.save 'map' delim 'original.png'],'-r400');
    export_fig(ax3,[path.save 'map' delim 'interpolated.png'],'-r400');
    export_fig(ax4,[path.save 'map' delim 'masked.png'],'-r400');
    export_fig(ax5,[path.save 'map' delim 'difference.png'],'-r400');
end
if save_figs == 1 && geo_data == 1
    export_fig(ax1,[path.save 'geo' delim 'mask.png'],'-r400');
    export_fig(ax2,[path.save 'geo' delim 'original.png'],'-r400');
    export_fig(ax3,[path.save 'geo' delim 'interpolated.png'],'-r400');
    export_fig(ax4,[path.save 'geo' delim 'masked.png'],'-r400');
    export_fig(ax5,[path.save 'geo' delim 'difference.png'],'-r400');
end

