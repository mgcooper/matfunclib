function drawarrow(x_start, y_start, x_end, y_end, varargin)
   % Normalize axes units to prepare for annotation function
   ax = gca;
   ax.Units = 'normalized';

   % Get the figure and axis position information
   figpos = ax.Position;
   axxlim = ax.XLim;
   axylim = ax.YLim;

   % Normalize the start and end coordinates
   x_start = (x_start - axxlim(1)) / (axxlim(2) - axxlim(1)) * figpos(3) + figpos(1);
   y_start = (y_start - axylim(1)) / (axylim(2) - axylim(1)) * figpos(4) + figpos(2);
   x_end = (x_end - axxlim(1)) / (axxlim(2) - axxlim(1)) * figpos(3) + figpos(1);
   y_end = (y_end - axylim(1)) / (axylim(2) - axylim(1)) * figpos(4) + figpos(2);

   % Set up default properties
   defaultProperties = {'HeadStyle', 'plain', 'HeadLength', 6, ...
      'HeadWidth', 6, 'LineWidth', 1};

   % Override defaults if additional properties are provided
   if ~isempty(varargin)
      properties = varargin;
   else
      properties = defaultProperties;
   end

   % Draw the arrows
   for n = 1:numel(x_start)
      annotation('arrow', [x_start(n), x_end(n)], ...
         [y_start(n), y_end(n)], properties{:});
   end
end


% function draw_arrow(x_start, y_start, x_end, y_end)
% % Normalize axes units to prepare for annotation function
% ax = gca;
% ax.Units = 'normalized';
%
% % Get the figure and axis position information
% figpos = ax.Position;
% axxlim = ax.XLim;
% axylim = ax.YLim;
%
% % Normalize the start and end coordinates
% x_start = (x_start - axxlim(1)) / (axxlim(2) - axxlim(1)) * figpos(3) + figpos(1);
% y_start = (y_start - axylim(1)) / (axylim(2) - axylim(1)) * figpos(4) + figpos(2);
% x_end = (x_end - axxlim(1)) / (axxlim(2) - axxlim(1)) * figpos(3) + figpos(1);
% y_end = (y_end - axylim(1)) / (axylim(2) - axylim(1)) * figpos(4) + figpos(2);
%
% % Draw the arrows
% for n = 1:numel(x_start)
%    annotation('arrow', [x_start(n), x_end(n)], ...
%       [y_start(n), y_end(n)]);
% end
%
% end
