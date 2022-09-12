function setXticks( nticks )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

ax              =   gca;
myaxistight(ax,'x');
children        =   ax.Children;
Xdata           =   children.XData;
Ydata           =   children.YData;
Xlims           =   ax.XLim;
Ylims           =   ax.YLim;

ax.XTick        =   linspace(Xdata(1),Xdata(end),12);

% use ax lims instead of data limits in case I have not (or don't want)
% axis tight
ax.XTick        =   linspace(Xlims(1),Xlims(2),12);

ax.XTick        =   (Xlims(1):nticks-2:Xlims(2));
end

