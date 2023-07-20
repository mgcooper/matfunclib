function smartlabels(XData, YData, labels, varargin)
%SMARTLABELS add labels to plot smartly, using labelpoints
% 
% smartlabels(XData, YData, labels)
% smartlabels(XData, YData, 'FontSize', 12)
% 
% Accepts all arguments to labelpoints in varargin
% 
% See also labelpoints

% Get default position
valid_positions = ...
   {'NE', 'SE', 'NW', 'SW', 'N', 'S', 'E', 'W', 'C', 'center'};
default_pos = 'NE';
[default_pos, args, nargs] = parseoptarg(varargin, valid_positions, default_pos);

% Get axis limits
xlims = xlim();
ylims = ylim();

% Calculate range manually
xrange = max(XData) - min(XData);
yrange = max(YData) - min(YData);

% Calculate thresholds for 'near edge' and 'near other points'
edge_thresh = 0.1 * xrange; % 10% of x range for determining edge proximity
overlap_thresh = 0.1 * xrange; % 2% of x range for determining overlap with other points

% Initialize label positions to 'NE'
pos = repmat({default_pos}, size(XData));

% 9 Jul 2023, commented this out - not sure why this was even used, but
% occassionally it is nice to have the edges automatically moved e.g. right edge
% would be 'E', left edge 'W', top 'N', bottom 'S', so this could form the basis
% for that
% Adjust label positions if near right edge
for i = 1:length(XData)
   x = XData(i);
   y = YData(i);
   if x > xlims(2) - edge_thresh % near right edge
      % pos{i} = 'NW';
   end
end

% Further adjust label positions to avoid overlap
for i = 1:length(XData)
   for j = (i+1):length(XData)
      if abs(XData(i) - XData(j)) < overlap_thresh && abs(YData(i) - YData(j)) < overlap_thresh
         if XData(i) < XData(j) % if point i is to the left of point j
            pos{i} = 'NW'; % to go up down: pos{i} = 'SE';
            pos{j} = 'NE';
         else % if point i is to the right of point j
            pos{i} = 'NE';
            pos{j} = 'NW'; % pos{j} = 'SE';
         end
      end
   end
end

% Apply labels
for i = 1:length(XData)
   labelpoints(XData(i), YData(i), labels(i), pos{i}, 0.1, args{:});
end
end

% function smartlabels(XData, YData, labels)
%     % Get axis limits
%     xlims = xlim();
%     ylims = ylim();
%     
%     % Calculate range manually
%     xrange = max(XData) - min(XData);
%     yrange = max(YData) - min(YData);
%     
%     % Calculate thresholds for 'near edge'
%     xthresh = 0.1 * xrange; % 10% of x range
%     ythresh = 0.1 * yrange; % 10% of y range
% 
%     % Loop over all points
%     for i = 1:length(XData)
%         x = XData(i);
%         y = YData(i);
% 
%         % Determine label position based on proximity to edge
%         if x > xlims(2) - xthresh % near right edge
%             pos = 'NW';
%         elseif x < xlims(1) + xthresh % near left edge
%             pos = 'NE';
%         else % everywhere else
%             pos = 'NE';
%         end
%         
%         % Apply label
%         labelpoints(x, y, labels(i), pos, 0.1);
%     end
% end
