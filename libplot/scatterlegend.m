function L = scatterlegend(ax, s, C)
   %SCATTERLEGEND Create a legend for a filled scatterplot
   %
   % Creates a legend for a 'filled' scatterplot from the
   % scatter handle s and grouping variable C used to define the color order
   %
   %   l = scatterlegend(gca,s,C) creates a legend for axis gca
   %
   % See also: scatterfit

   if isempty(ax)
      ax = gca;
   end
   
   % get the axis limits
   hold on;
   xlims = get(ax, 'XLim');
   ylims = get(ax, 'YLim');
   xdata = get(s, 'XData');
   ydata = get(s, 'YData');
   sz = get(s, 'SizeData');

   % figure out how many unique groups (colors) are in the plot
   [~, I] = unique(C);
   ncolors = length(I);
   si = I(1:end-1);
   ei = I(2:end);
   % build a distinguishable colors list
   colors = distinguishable_colors(ncolors);

   for n = 1:length(I)-1
      si_n = si(n);
      ei_n = ei(n)-1;
      colorsrep(si_n:ei_n,:) = repmat(colors(n,:),ei_n-si_n+1,1);
   end

   % replot the data
   s = scatter(xdata,ydata,sz,colors,'filled');
   
   % add dummy plots for each group
   for n = 1:ncolors
      p(n) = scatter(0,0,'MarkerFaceColor',colors(n,:));
   end

   set(gca,'XLim',xlims);
   set(gca,'YLim',ylims);

   % add the legend
   L = legend(p);


   %%%%

   hold on;
   % figure out how many unique groups (colors) are in the plot
   [~, I] = unique(C);
   npoints = length(C);
   ngroups = length(I);
   dummy = scatter(zeros(size(C)),zeros(size(C)),C);

   % can I add dummy plots

   % can i get the color order and index in?
   colororder = get(gca,'ColorOrder');
   colors = colororder(1:3,:);
   scatter(4,4,'MarkerFaceColor',colors(1,:),'MarkerEdgeColor',colors(1,:))
   scatter(5,4,'MarkerFaceColor',colors(2,:),'MarkerEdgeColor',colors(2,:))
   scatter(6,4,'MarkerFaceColor',colors(3,:),'MarkerEdgeColor',colors(3,:))
end
