function mycontourf( data )
%MYCONTOURF like contourf but adds a colorbar, sets axes equal and limits
%on axes. Does not flipud

[a,b,c] = size(data);
contourf(data);colorbar;axis equal;set(gca,'XLim',[1 b],'YLim',[1 a]);
