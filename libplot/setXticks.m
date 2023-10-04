function setXticks( nticks )
   %SETXTICKS Set xticks to a defined number of values
   %
   % setXticks(nticks)
   %
   % See also:
   
   % Note: I don't think this function is finished.

   ax = gca;
   tightaxis(ax, 'x');

   child = get(ax, 'Children');
   Xdata = get(child, 'XData');
   Ydata = get(child, 'YData');
   Xlims = get(ax, 'XLim');
   Ylims = get(ax, 'YLim');

   % Original method:
   % newticks = linspace(Xdata(1), Xdata(end), nticks);
   
   % Revised method: use axes limits instead of data limits in case I have not
   % (or don't want) axis tight 
   newticks = linspace(Xlims(1), Xlims(2), nticks);
   
   % Another method, not sure why this was used
   % newticks = Xlims(1):nticks-2:Xlims(2);

   set(ax, 'XTick', newticks);
end
