clean

save_figs   =   1;
save_data   =   0;
path.save   =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/myFunctions/' ...
                    'raster/rasterref/test/figs/'];
                
%%
% in addition to what I've done below, I need to:

% 1. check ltln2val
% 2. check if I can use 'Cells' and if ncols/cellsize != latlim(2)-latlim(2),
% then add another another cell width to the lat/lon limits

%%
Z           =   [ 1   2   3   4  ; ...
                  5   6   7   8  ; ...
                  9   10  11  12 ; ...
                  13  14  15  16 ];

LAT         =   [ 30  30  30  30 ; ...
                  0   0   0   0  ; ...
                 -30 -30 -30 -30 ; ...
                 -60 -60 -60 -60 ];

LON         =   [ 0   30  60  90 ;...
                  0   30  60  90 ;...
                  0   30  60  90 ;...
                  0   30  60  90 ];
              
lon         =   [ 0   30  60  90 ];
lat         =   [ 30  0  -30 -60 ];

% this gives the same result as LON and LAT
[LONg,LATg] =   meshgrid(lon,lat);

%% georeference                
cellsize    =   30;                
halfcell    =   cellsize/2;

% in-build Matlab
Rcell1      =   georefcells([-60 30],[0 90],size(Z),'ColumnsStartFrom','north');
Rpost1      =   georefpostings([-60 30],[0 90],size(Z),'ColumnsStartFrom','north');
Rpost2cell1 =   Rpost2cells(Rcell1);

% rasterref
Rcell2      =   rasterref(LONg,LATg,'cells');
Rpost2      =   rasterref(LONg,LATg,'posting');
Rpost2cell2 =   Rpost2cells(Rcell2);

%% geoshow 'surface' and LAT LON
[h.f1,h.ax1]    =   testrefplot(); hold on;
h.g1            =   geoshow(LAT,LON,Z,'DisplayType','surface'); 
h.g1.ZData      =   zeros(size(Z));
h.l1            =   textm(LAT(:),LON(:),num2str(Z(:)),'Color','blue');
h.c1            =   colorbar('eastoutside');
h.t1            =   title('Matlab geoshow(LAT,LON,Z,''surface'')');

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_lat_lon_z_surface.png'],'-r300');
end
%% geoshow 'texturemap' and LAT LON
[h.f2,h.ax2]    =   testrefplot(); hold on;
h.g2            =   geoshow(LAT,LON,Z,'DisplayType','texturemap');
h.g2.ZData      =   zeros(size(Z));
h.l2            =   textm(LAT(:),LON(:),num2str(Z(:)),'Color','blue');
h.c2            =   colorbar('eastoutside');
h.t2            =   title('Matlab geoshow(LAT,LON,Z,''texturemap'')');

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_lat_lon_z_texture.png'],'-r300');
end
% ht          =   textm(LAT(:)-halfcell,LON(:)+halfcell,num2str(Z(:)), ...
%                     'Color','blue','FontSize',14);

%% grid2image and Matlab Rcells
h.f3            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g3            =   grid2image(Z,Rcell1); hold on;
h.b3            =   plotRbox(Rcell1,'g','linewidth',3);
h.ax3           =   gca; axis image
h.ax3.XLim      =   [-15 105];
h.ax3.YLim      =   [-75 45];
h.ax3.XTick     =   [0 30 60 90];
h.ax3.YTick     =   [-60 -30 0 30];
h.c3            =   colorbar('eastoutside');
h.l3            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t3            =   title('Matlab grid2image(Z,RCell1)');
h.ax3.XAxis.MinorTick       =   'on';
h.ax3.YAxis.MinorTick       =   'on';
h.ax3.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax3.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax3.TickLength            =   1.5.*h.ax3.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_grid2image_z_rcell1.png'],'-r300');
end

%% grid2image and rasterref Rcells
h.f4            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g4            =   grid2image(Z,Rcell2); hold on;
h.b4            =   plotRbox(Rcell2,'g','linewidth',3);
h.ax4           =   gca; axis image
h.ax4.XLim      =   [-15 105];
h.ax4.YLim      =   [-75 45];
h.ax4.XTick     =   [0 30 60 90];
h.ax4.YTick     =   [-60 -30 0 30];
h.c4            =   colorbar('eastoutside');
h.l4            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t4            =   title('Rasterref grid2image(Z,RCell2)');
h.ax4.XAxis.MinorTick       =   'on';
h.ax4.YAxis.MinorTick       =   'on';
h.ax4.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax4.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax4.TickLength            =   1.5.*h.ax4.TickLength;
% h.ax4.XAxis.Visible         =   'off';
% h.ax4.YAxis.Visible         =   'off';

if save_figs == 1
    export_fig([path.save 'matlab_grid2image_z_recell2.png'],'-r300');
end
%% repeat with 'image' using grid2image and Rpost2Cells

% NOTE: identical to Rcells

% h.f4            =   figure('Color','white','Colormap',autumn(64));
% h.g4            =   grid2image(Z,Rpostcells); 
% h.ax4           =   gca; axis image
% h.ax4.XLim      =   [-10 100];
% h.ax4.YLim      =   [-70 40];
% h.ax4.XTick     =   [0 30 60 90];
% h.ax4.YTick     =   [-60 -30 0 30];
% h.c4            =   colorbar('eastoutside');
% h.l4            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
% h.t4            =   title('Matlab grid2image(Z,Rpost2cells)');

%% pcolor
h.f5            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g5            =   pcolor(LON,LAT,Z); 
h.ax5           =   gca; axis image
h.ax5.XLim      =   [-15 105];
h.ax5.YLim      =   [-75 45];
h.ax5.XTick     =   [0 30 60 90];
h.ax5.YTick     =   [-60 -30 0 30];
h.c5            =   colorbar('eastoutside');
h.l5            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t5            =   title('Matlab pcolor(LON,LAT,Z)');
h.ax5.XAxis.MinorTick       =   'on';
h.ax5.YAxis.MinorTick       =   'on';
h.ax5.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax5.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax5.TickLength            =   1.5.*h.ax5.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_pcolor_lat_lon_z.png'],'-r300');
end

%% imagesc
h.f6            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g6            =   imagesc(unique(LON),unique(LAT),Z); 
h.ax6           =   gca; axis image
h.ax6.XLim      =   [-15 105];
h.ax6.YLim      =   [-75 45];
h.ax6.XTick     =   [0 30 60 90];
h.ax6.YTick     =   [-60 -30 0 30];
h.c6            =   colorbar('eastoutside');
h.l6            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t6            =   title('Matlab imagesc(LON,LAT,Z)');
h.ax6.XAxis.MinorTick       =   'on';
h.ax6.YAxis.MinorTick       =   'on';
h.ax6.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax6.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax6.TickLength            =   1.5.*h.ax6.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_imagesc_lat_lon_z.png'],'-r300');
end

%% geoshow surface and Matlab Rcells
h.f7            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g7            =   geoshow(Z,Rcell1,'DisplayType','surface','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax7           =   gca; axis image
h.b7            =   plotRbox(Rcell1,'g','linewidth',3);
h.ax7.XLim      =   [-15 105];
h.ax7.YLim      =   [-75 45];
h.ax7.XTick     =   [0 30 60 90];
h.ax7.YTick     =   [-60 -30 0 30];
h.c7            =   colorbar('eastoutside');
h.l7            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t7            =   title('Matlab geoshow(Z,RCell1,''surface'')');
h.ax7.XAxis.MinorTick       =   'on';
h.ax7.YAxis.MinorTick       =   'on';
h.ax7.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax7.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax7.TickLength            =   1.5.*h.ax7.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_z_rcell1_surface.png'],'-r300');
end
%% geoshow surface and rasterref Rcells
h.f8            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g8            =   geoshow(Z,Rcell2,'DisplayType','surface','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax8           =   gca; axis image
h.b8            =   plotRbox(Rcell2,'g','linewidth',3);
h.ax8.XLim      =   [-15 105];
h.ax8.YLim      =   [-75 45];
h.ax8.XTick     =   [0 30 60 90];
h.ax8.YTick     =   [-60 -30 0 30];
h.c8            =   colorbar('eastoutside');
h.l8            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t8            =   title('Rasterref geoshow(Z,RCell2,''surface'')');
h.ax8.XAxis.MinorTick       =   'on';
h.ax8.YAxis.MinorTick       =   'on';
h.ax8.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax8.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax8.TickLength            =   1.5.*h.ax8.TickLength;

if save_figs == 1
    export_fig([path.save 'rasterref_geoshow_z_rcell2_surface.png'],'-r300');
end

%% geoshow surface and Matlab Rposts
h.f9            =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g9            =   geoshow(Z,Rpost1,'DisplayType','surface','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax9           =   gca; axis image
h.b9            =   plotRbox(Rpost1,'g','linewidth',3);
h.ax9.XLim      =   [-15 105];
h.ax9.YLim      =   [-75 45];
h.ax9.XTick     =   [0 30 60 90];
h.ax9.YTick     =   [-60 -30 0 30];
h.c9            =   colorbar('eastoutside');
h.l9            =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t9            =   title('Matlab geoshow(Z,RPost1,''surface'')');
h.ax9.XAxis.MinorTick       =   'on';
h.ax9.YAxis.MinorTick       =   'on';
h.ax9.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax9.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax9.TickLength            =   1.5.*h.ax9.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_z_rpost1_surface.png'],'-r300');
end
%% geoshow surface and rasterref Rposts
h.f10           =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g10           =   geoshow(Z,Rpost2,'DisplayType','surface','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax10          =   gca; axis image
h.b10           =   plotRbox(Rpost2,'g','linewidth',3);
h.ax10.XLim     =   [-15 105];
h.ax10.YLim     =   [-75 45];
h.ax10.XTick    =   [0 30 60 90];
h.ax10.YTick    =   [-60 -30 0 30];
h.c10           =   colorbar('eastoutside');
h.l10           =   text(h.ax10,LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t10           =   title('Rasterref geoshow(Z,RPost2,''surface'')');
h.ax10.XAxis.MinorTick       =   'on';
h.ax10.YAxis.MinorTick       =   'on';
h.ax10.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax10.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax10.TickLength            =   1.5.*h.ax10.TickLength;

if save_figs == 1
    export_fig([path.save 'rasterref_geoshow_z_rpost2_surface.png'],'-r300');
end

%% geoshow texture and Matlab Rcells
h.f11           =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g11           =   geoshow(Z,Rcell1,'DisplayType','texturemap','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax11          =   gca; axis image
h.b11           =   plotRbox(Rcell1,'g','linewidth',3);
h.ax11.XLim     =   [-15 105];
h.ax11.YLim     =   [-75 45];
h.ax11.XTick    =   [0 30 60 90];
h.ax11.YTick    =   [-60 -30 0 30];
h.c11           =   colorbar('eastoutside');
h.l11           =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t11           =   title('Matlab geoshow(Z,RCell1,''texturemap'')');
h.ax11.XAxis.MinorTick       =   'on';
h.ax11.YAxis.MinorTick       =   'on';
h.ax11.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax11.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax11.TickLength            =   1.5.*h.ax11.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_z_rcell1_texture.png'],'-r300');
end

%% geoshow texture and rasterref Rcells
h.f12           =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g12           =   geoshow(Z,Rcell2,'DisplayType','texturemap','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax12          =   gca; axis image
h.b12           =   plotRbox(Rcell2,'g','linewidth',3);
h.ax12.XLim     =   [-15 105];
h.ax12.YLim     =   [-75 45];
h.ax12.XTick    =   [0 30 60 90];
h.ax12.YTick    =   [-60 -30 0 30];
h.c12           =   colorbar('eastoutside');
h.l12           =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t12           =   title('Rasterref geoshow(Z,RCell2,''texturemap'')');
h.ax12.XAxis.MinorTick       =   'on';
h.ax12.YAxis.MinorTick       =   'on';
h.ax12.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax12.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax12.TickLength            =   1.5.*h.ax12.TickLength;

if save_figs == 1
    export_fig([path.save 'rasterref_geoshow_z_rcell2_texture.png'],'-r300');
end

%% geoshow image and Matlab Rcells
h.f13           =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g13           =   geoshow(Z,Rcell1,'DisplayType','image','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax13          =   gca; axis image
h.b13           =   plotRbox(Rcell1,'g','linewidth',3);
h.ax13.XLim     =   [-15 105];
h.ax13.YLim     =   [-75 45];
h.ax13.XTick    =   [0 30 60 90];
h.ax13.YTick    =   [-60 -30 0 30];
h.c13           =   colorbar('eastoutside');
h.l13           =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t13           =   title('Matlab geoshow(Z,RCell1,''image'')');
h.ax13.XAxis.MinorTick       =   'on';
h.ax13.YAxis.MinorTick       =   'on';
h.ax13.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax13.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax13.TickLength            =   1.5.*h.ax13.TickLength;

if save_figs == 1
    export_fig([path.save 'matlab_geoshow_z_rcell1_image.png'],'-r300');
end

%% geoshow surface and rasterref Rcells
h.f14           =   figure('Color','white','Colormap',autumn(64), ... 
                            'Units','inches','Position',[1 1 5 4]);
h.g14           =   geoshow(Z,Rcell2,'DisplayType','image','ZData', ...
                        zeros(size(Z)),'CData',Z); hold on;
h.ax14          =   gca; axis image
h.b14           =   plotRbox(Rcell2,'g','linewidth',3);
h.ax14.XLim     =   [-15 105];
h.ax14.YLim     =   [-75 45];
h.ax14.XTick    =   [0 30 60 90];
h.ax14.YTick    =   [-60 -30 0 30];
h.c14           =   colorbar('eastoutside');
h.l14           =   text(LON(:),LAT(:),num2str(Z(:)),'Color','blue');
h.t14           =   title('Rasterref geoshow(Z,RCell2,''image'')');
h.ax14.XAxis.MinorTick       =   'on';
h.ax14.YAxis.MinorTick       =   'on';
h.ax14.XAxis.MinorTickValues =   [-15 15 45 75 105];
h.ax14.YAxis.MinorTickValues =   [-75 -45 -15 15 45];
h.ax14.TickLength            =   1.5.*h.ax14.TickLength;

if save_figs == 1
    export_fig([path.save 'rasterref_geoshow_z_rcell2_image.png'],'-r300');
end

%% check ltln2val
latq            =   0;
lonq            =   -16:1:106;
for n = 1:length(lonq)
    valRcell1(n)        =   ltln2val(Z,Rcell1,latq,lonq(n),'nearest');
    valRcell2(n)        =   ltln2val(Z,Rcell2,latq,lonq(n),'nearest');
    valRpost1(n)        =   ltln2val(Z,Rpost1,latq,lonq(n),'nearest');
    valRpost2(n)        =   ltln2val(Z,Rpost2,latq,lonq(n),'nearest');
    valRpostcell1(n)    =   ltln2val(Z,Rpost2cell1,latq,lonq(n),'nearest');
    valRpostcell2(n)    =   ltln2val(Z,Rpost2cell2,latq,lonq(n),'nearest');
end

% what should it equal?
ltlncorrect             =   [nan 5.*ones(1,30) 6.*ones(1,30) 7.*ones(1,30) ...
                                8.*ones(1,30) nan nan];

ltln2values             =   [lonq; valRcell1; valRcell2; valRpost1; valRpost2; ...
                                valRpostcell1; valRpostcell2; ltlncorrect];
ltln2values             =   ltln2values';
ltln2values             =   array2table(ltln2values,'VariableNames', ...
                                {'Lon','Matlab Rcell','RasterRef Rcell', ...
                                'Matlab Rpost','RasterRef Rpost', ...
                                'Matlab Rpost2Cell', ...
                                'RasteRef Rpost2Cell', 'Correct'});
if save_data == 1
    writetable(ltln2values,[path.save 'ltln2values.xlsx']);
end
% valcells = ltln2val(A,Rcell,latq,lonq)
% valpostings = ltln2val(A,Rpost,latq,lonq)
% valpost2cells = ltln2val(A,Rpost2cells,latq,lonq)

%%
% [LON2,LAT2]     =   meshgrid(10:10:40,60:10:90);
% h.f13           =   figure('Color','white','Colormap',autumn(64), ... 
%                             'Units','inches','Position',[1 1 5 4]);
% pcolorpsn(LAT2,LON2,Z);

%% Results

% 'Postings' cannot be used with 'texturemap', only 'surface', 'mesh'


%% compare the XLim/YLims
% (max(LON(:))-min(LON(:)))/4
% ((max(LON(:))+halfcell)-(min(LON(:))-halfcell))/4
% h.ax5.XLim

%% this is how i was testing the bounding box offset

% deltaY      =   5000;
% deltaX      =   5000;
% 
% uplefty     =   Rrb.YWorldLimits(2)-deltaY;
% upleftx     =   Rrb.XWorldLimits(1)+deltaX;
% uprightx    =   Rrb.XWorldLimits(2)+deltaX;
% uprighty    =   Rrb.YWorldLimits(2)-deltaY;
% lowlefty    =   Rrb.YWorldLimits(1)-deltaY;
% lowleftx    =   Rrb.XWorldLimits(1)+deltaX;
% lowrighty   =   Rrb.YWorldLimits(1)-deltaY;
% lowrightx   =   Rrb.XWorldLimits(2)+deltaX;
% coords.y    =   [uprighty uplefty lowlefty lowrighty uprighty];
% coords.x    =   [uprightx upleftx lowleftx lowrightx uprightx];
% h           =   plot(ax,coords.x,coords.y);

% so ... somewhere the sampling box is being shifted by 1/2 cell size ...


%%
% this illustrates the problem - In the first version (surface) matlab is
% displaying the data such that the values in the data matrix set the color
% map at the upper left corners. The 5th row and 5th column are missing.
% In the second version (texturmap), the data matrix is squeezed into the
% LAT/LON limits, so four 'cells' are displayed, but they are squeezed into
% the three cells formed by the LAT/LON limits. 
% We want something different. We want the data values to represent the
% centroids of the 'cells', and therefore we need to adjust the lat/lon
% limits.

% %% below is the original version
% clean
% 
% % see https://www.mathworks.com/help/map/geographic-interpretations-of-geolocated-grids.html
% 
% path.data   =   ['/Users/mattcooper/Dropbox/CODE/MATLAB/myFunctions/' ...
%                     'raster/rasterref/test/'];
% 
% list        =   dir(fullfile([path.data '*.nc']));
% ncfile      =   [path.data list(1).name];
% info        =   ncinfo(ncfile);
% var         =   'MYD08_D3_6_AOD_550_Dark_Target_Deep_Blue_Combined_Mean';
% lat         =   double(ncread(ncfile,'lat'));
% lon         =   double(ncread(ncfile,'lon'));
% A           =   ncread(ncfile,var);
% % R           =   georasterref(   'RasterSize',       size(A), ...
% %                                 'LatitudeLimits',   [min(lat),max(lat)], ...
% %                                 'LongitudeLimits',  [min(lon),max(lon)]);
% Rcell      =   georefcells(    [min(lat),max(lat)], ...
%                                 [min(lon),max(lon)], ...
%                                 size(A));                            
% tiffile     =   'example_cells.tif';
% 
% geotiffwrite(tiffile,A,Rcell)
% 
% % now test how R is interpreted on the way back in
% [~,Rcell]  =   geotiffread(tiffile);
% 
% % sure enough, not correct. use georefpostings instead
% Rpost       =   georefpostings( [min(lat),max(lat)], ...
%                                 [min(lon),max(lon)], ...
%                                 size(A));
% tiffile     =   'example_postings.tif';
% geotiffwrite(tiffile,A,Rpost)
% 
% [~,Rpost]   =   geotiffread(tiffile);
% 
% %% Note - I can convert the 'Postings' object to a 'Cells' object
% 
% test        =   worldFileMatrixToRefmat(Rpost.worldFileMatrix);
% Rpost2cells =   refmatToGeoRasterReference(test,size(A));
% 
% % this yields a RasterExtentInLatitude and RasterExtentInLongitude that is
% % correct with respect to the extent of the .tif written by geotiffwrite
% % using the 'Postings' spatial object
% 
% tiffile     =   'example_post2cells.tif';
% geotiffwrite(tiffile,A,Rpost2cells)
% 
% [~,Rpost2cells]   =   geotiffread(tiffile);
% 
% %%
% figure
% geoshow(A,Rcell,'DisplayType','mesh')
% title('Cells')
% 
% figure
% geoshow(A,Rpost,'DisplayType','mesh','FaceColor','flat','EdgeColor','flat')
% title('Postings')
% % shading faceted
% 
% figure
% geoshow(A,Rpost2cells,'DisplayType','surface')
% title('Postings 2 Cells')
% 
% 
% %% test effect on ltln2val
% 
% latq = 28.12;
% lonq = 72.2;
% 
% valcells = ltln2val(A,Rcell,latq,lonq)
% valpostings = ltln2val(A,Rpost,latq,lonq)
% valpost2cells = ltln2val(A,Rpost2cells,latq,lonq)

