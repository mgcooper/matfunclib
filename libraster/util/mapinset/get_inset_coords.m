function inset_xy = get_inset_coords(ax_main,pos_main,pos_inset,           ...
                            xlim_main,ylim_main,xlim_inset,             ...
                            ylim_inset,vertex)        

% horizontal distance from lower left edge main to lower left edge inset
dLeft   = pos_inset(1)-pos_main(1);
% horizontal distance from lower left edge main to lower right edge inset
dRight  = pos_inset(1)+pos_inset(3)-pos_main(1);
wMain   = pos_main(3);                  % width, main axis
dxMain  = diff(xlim_main);              % width in map units, main axis
x1Main  = xlim_main(1);

% vertical distance from lower left edge main to lower left edge inset
dLow    = pos_inset(2)-pos_main(2);
% vertical distance from lower left edge main to upper left edge inset
dHigh   = pos_inset(2)-pos_main(2)+pos_inset(4);
hMain   = pos_main(4); 
dyMain  = diff(ylim_main);
y1Main  = ylim_main(1);

% these are supposed to be the x,y of the inset in terms of the main fig
x1      = dLeft / wMain  * dxMain + x1Main; 
y1      = dLow / hMain * dyMain + y1Main;

x2      = dRight / wMain * dxMain + x1Main;
y2      = dHigh / hMain  * dyMain + y1Main;

% Plot lines connecting zoomPlot to original plot points
% if any(vertex==1) % upper left
%     plot(ax_main,[xlim_inset(1) x1], [max(ylim_inset) y2],'k','LineWidth',1); % Line to vertex 1
% end
% if any(vertex==2) % upper right
%     plot(ax_main,[xlim_inset(2) x2], [max(ylim_inset) y2],'k','LineWidth',1); % Line to vertex 2
% end
% if any(vertex==3) % lower right
%     plot(ax_main,[xlim_inset(2) x2], [min(ylim_inset) y1],'k','LineWidth',1); % Line to vertex 4
% end
% if any(vertex==4) % lower left
%     plot(ax_main,[xlim_inset(1) x1], [min(ylim_inset) y1],'k','LineWidth',1); % Line to vertex 3
% end


% inset_xy.x1     = x1;
% inset_xy.y1     = y1;
% inset_xy.x2     = x2;
% inset_xy.y2     = y2;


inset_xy.xUR    = [xlim_inset(2) x2];
inset_xy.yUR    = [max(ylim_inset) y2];
inset_xy.xLL    = [xlim_inset(1) x1];
inset_xy.yLL    = [min(ylim_inset) y1];

inset_xy.xLR    = [xlim_inset(2) x2];
inset_xy.yLR    = [min(ylim_inset) y1];
inset_xy.xUL    = [xlim_inset(1) x1];
inset_xy.yUL    = [max(ylim_inset) y2];


end




