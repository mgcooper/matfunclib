clean

save_figs = 1;
path.save = ['/Users/mattcooper/Dropbox/CODE/MATLAB/myFunctions/raster/' ...
                'rasterref/test/figs/warp/'];
%%
lat = [0 30 60];
lon = [40 70 100];
Z   = [ 1 2 3;
        1 2 3;
        1 2 3];
Z   = Z';

xbox1 = [25 55 55 25 25];
ybox1 = [-15 -15 75 75 -15];
xbox2 = [40 70 70 40 40];
ybox2 = [-30 -30 60 60 -30];
xbox3 = [40 60 60 40 40];
ybox3 = [0 0 60 60 0];
    
RcellRaster = rasterref(lon,lat,'Cell');
RpostRaster = rasterref(lon,lat,'Posting');
RcellMatlab = georefcells([min(lat) max(lat)],[min(lon) max(lon)],size(Z), ...
                'ColumnsStartFrom','north');
RpostMatlab = georefpostings([min(lat) max(lat)],[min(lon) max(lon)],size(Z), ...
                'ColumnsStartFrom','north');

Rcustom     = RcellMatlab;
Rcustom.LatitudeLimits = [-30 60];
Rcustom.CellExtentInLatitude = 30;
Rcustom.LongitudeLimits = [40 130];

            
figure;
geoshow(Z,RcellRaster,'DisplayType','image','ZData',zeros(size(Z)),'CData',Z); 
hold on;
plot(xbox1,ybox1,'r');
plot([lon(1) lon(1) lon(1)],lat,'ro','MarkerFaceColor','r');
plot([lon(2) lon(2) lon(2)],lat,'ro','MarkerFaceColor','r');
plot([lon(3) lon(3) lon(3)],lat,'ro','MarkerFaceColor','r');
text(lon(1)-3,lat(1)-5,'(40,0)','Color','r')
text(lon(1)-3,lat(2)-5,'(40,30)','Color','r')
text(lon(1)-3,lat(3)-5,'(40,60)','Color','r')
c = colorbar('Ticks',[1 2 3]);
colormap(parula(3));
c.Position(4) = 0.5*c.Position(4);
c.Position(1) = 1.05*c.Position(1);
c.Position(2) = 3*c.Position(2);
set(gca,'XLim',[20 140]);
set(gca,'YLim',[-40 80]);
xlabel('Longitude');
ylabel('Latitude');
title('Postings Interpretation');
if save_figs == 1
    export_fig([path.save 'postings.png'],'-r300');
end

figure;
geoshow(Z,Rcustom,'DisplayType','image','ZData',zeros(size(Z)),'CData',Z); 
hold on;
plot(xbox2,ybox2,'r');
plot([lon(1) lon(1) lon(1)],lat,'ro','MarkerFaceColor','r');
plot([lon(2) lon(2) lon(2)],lat,'ro','MarkerFaceColor','r');
plot([lon(3) lon(3) lon(3)],lat,'ro','MarkerFaceColor','r');
text(lon(1)+1,lat(1)-3,'(40,0)','Color','r')
text(lon(1)+1,lat(2)-3,'(40,30)','Color','r')
text(lon(1)+1,lat(3)-3,'(40,60)','Color','r')
c = colorbar('Ticks',[1 2 3]);
colormap(parula(3));
c.Position(4) = 0.5*c.Position(4);
c.Position(1) = 1.05*c.Position(1);
c.Position(2) = 3*c.Position(2);
set(gca,'XLim',[20 140]);
set(gca,'YLim',[-40 80]);
xlabel('Longitude');
ylabel('Latitude');
title('Cell Interpretation');
if save_figs == 1
    export_fig([path.save 'cells.png'],'-r300');
end

figure;
geoshow(Z,RcellMatlab,'DisplayType','image','ZData',zeros(size(Z)),'CData',Z); 
hold on;
plot(xbox3,ybox3,'r');
plot([lon(1) lon(1) lon(1)],lat,'ro','MarkerFaceColor','r');
plot([lon(2) lon(2) lon(2)],lat,'ro','MarkerFaceColor','r');
plot([lon(3) lon(3) lon(3)],lat,'ro','MarkerFaceColor','r');
text(lon(1),lat(1)-3,'(40,0)','Color','r')
text(lon(1),lat(2)-3,'(40,30)','Color','r')
text(lon(1),lat(3)-3,'(40,60)','Color','r')
c = colorbar('Ticks',[1 2 3]);
colormap(parula(3));
c.Position(4) = 0.5*c.Position(4);
c.Position(1) = 1.05*c.Position(1);
c.Position(2) = 3*c.Position(2);
set(gca,'XLim',[20 140]);
set(gca,'YLim',[-40 80]);
xlabel('Longitude');
ylabel('Latitude');
title('Warp Interpretation');
if save_figs == 1
    export_fig([path.save 'warp.png'],'-r300');
end

            