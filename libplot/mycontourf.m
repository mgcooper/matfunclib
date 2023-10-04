function mycontourf( data )
   %MYCONTOURF Contourf with colorbar, axes equal and tight limits
   %
   %
   % See also:
   
   [a,b,c] = size(data);
   contourf(data);
   colorbar;
   axis equal;
   set(gca,'XLim',[1 b],'YLim',[1 a]);
end