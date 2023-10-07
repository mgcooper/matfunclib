function topax = addtopaxis(ax)
   %ADDTOPAXIS Add a top axis to a figure
   %
   %  topax = addtopaxis()
   %  topax = addtopaxis(ax)
   %
   % See also:

   if nargin < 1
      ax = gca;
   end
   axpos = plotboxpos(ax);
   topax = axes('Position', axpos, 'Color', 'none');

   set(topax, 'XAxisLocation', 'top', 'YAxisLocation', 'Right', ...
      'XLim', get(ax, 'XLim'), 'XTick', get(ax, 'XTick'), 'XTickLabel', '');

   % The Y-versions of above and stuff below were commented out, not sure why
   % set(topax, 'YLim', get(ax, 'YLim'), 'YTick', get(ax, 'YTick'), 'XTickLabel', ...
   %    get(ax, 'XTickLabel'), 'YTickLabel', '');
   %
   % set(gcf, 'CurrentAxes', topax);

   % mainAxes = findobj(gcf, 'Type', 'axes');
   % newAxes = copyobj(mainAxes);
   % newAxes.Position = mainAxes.Position;
end
