function [ ax2 ] = addtopaxis( )
%ADDTOPAXIS add a top axis to a figure
   
ax1 = gca;
axpos = plotboxpos(ax1);
ax2 = axes('Position', axpos,'Color', 'none');

set(ax2, 'XAxisLocation', 'top', 'YAxisLocation', 'Right', ...
   'XLim', get(ax1, 'XLim'), 'XTick', get(ax1, 'XTick'), 'XTickLabel', '');

% The Y-versions of above and other stuff below were commented out, not sure why
% set(ax2, 'YLim', get(ax1, 'YLim'), 'YTick', get(ax1, 'YTick'), 'XTickLabel', ...
%    get(ax1, 'XTickLabel'), 'YTickLabel', '');
% 
% set(gcf,'CurrentAxes',ax2);

% mainAxes = findobj(gcf,'Type','axes');
% newAxes = copyobj(mainAxes);
% newAxes.Position = mainAxes.Position;


% % switched to set for octave compat
% ax2.XAxisLocation = 'top';
% ax2.YAxisLocation = 'Right';
% ax2.XLim = ax1.XLim;
% ax2.XTick = ax1.XTick;
% ax2.XTickLabel = '';

end

