function [f,ax] = testrefplot()
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

f           =   figure('Color','white','Colormap',autumn(64), ...
                        'Units','inches','Position',[1 1 5 4]);
ax          =   axesm('pcarree','Grid','on','Frame','on',...
                    'PLineLocation',30,'PLabelLocation',30, ...
                    'MapLatLimit',[-75 45],'MapLonLimit',[-15 105], ...
                    'MLabelParallel','south');
                mlabel; plabel; axis off; tightmap

% modify the graticule
% setm(ax,'PLineLocation',15)
% setm(ax,'MLineLocation',15)

% 
% s               =   scatterm(lat,lon,25,data,'filled');
% cmap            =   colormap(bluewhitered(256));
% 
% 
% 
% % hgrat = gridm('on'); 
% % set(hgrat,'Clipping','on')                
                
% h           =   geoshow(Z,R,'DisplayType',displaytype);
% h.ZData     =   zeros(size(Z));
% 
% handles.f   =   f;
% handles.ax  =   ax;
% handles.h   =   h;
end

