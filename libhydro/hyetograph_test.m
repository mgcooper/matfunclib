function [AX,H1,H2] = hyetograph( dates,ppt,flow,varargin )
%HYETOGRAPH Plots a discharge rainfall hyetograph
%   Detailed explanation goes here

[AX,H1,H2] = plotyy(dates,flow,dates,ppt,'plot','bar',varargin{:}); hold on;
bar(AX(2),dates,pet)

% Set bar graph properties
set(get(AX(2),'Ylabel'),'String','Precipitation (mm)','FontSize',16)
set(AX(2),'XTickLabel',[],'xaxislocation','top','YDir','reverse');

% Set line graph properties
set(get(AX(1),'Ylabel'),'String','Streamflow (mm)','FontSize',16)
set(AX(1),'XTickLabel', []);
set(AX(1),'FontSize',16);

% Print Month and Year as Tick Label
% datetick(AX(1),'x','mmm yyyy')
% datetick('x','mm/yy');

% Edit begin
% make sure the hyetograph and hydrograph don't overlap
% First make both axes 2x as long
AX(1).YLim(2)   =   2*AX(1).YLim(2);
AX(2).YLim(2)   =   2*AX(2).YLim(2);

% ylim1       =   AX(1).YLim;
% ylim2       =   AX(2).YLim;
% ymax1       =   max(flow(:,1));
% ymax2       =   max(ppt(:,1));
% scale       =   ylim2(2)/ylim1(2); % ratio of ppt/flow axis
% 
% if ymax2 > ymax1
% %     AX(2).YLim(2)   =   scale*(AX(2).YLim(2) + ymax1);
%     AX(2).YLim(2)   =   AX(2).YLim(2) + (scale*ymax1);
%     AX(1).YLim(2)   =   2*AX(1).YLim(2);
% end

% Edit end - 2x each axis seems to work

% format x tick lables 
datetick('x','mmm-yyyy');
% make sure the top/bottom x-axes are linked
linkaxes([AX(2) AX(1)],'x'); 
myaxistight(AX,'x');
% 
grid on
grid minor

% move the y lables 
ypos1                   =   AX(1).YLabel.Position;
ypos2                   =   AX(2).YLabel.Position;
ypos1(2)                =   ypos1(2)/1.8;
ypos2(2)                =   ypos2(2)/1.8;
AX(1).YLabel.Position   =   ypos1;
AX(2).YLabel.Position   =   ypos2;

end

