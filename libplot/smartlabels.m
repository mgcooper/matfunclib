function smartlabels(XData, YData, labels, varargin)
   %SMARTLABELS add labels to plot smartly, using labelpoints
   %
   % smartlabels(XData, YData, labels)
   % smartlabels(XData, YData, 'FontSize', 12)
   %
   % Accepts all arguments to labelpoints in varargin
   %
   % Note: this currently only adjusts the x direction, since text runs
   % left-right. The adjustments may not work for default label locations other
   % than 'NE'.
   % 
   % See also: labelpoints
   
   if iscategorical(labels)
      try
         labels = string(labels);
      catch ME
         rethrow(ME)
      end
   end

   % Get default position
   valid_positions = ...
      {'NE', 'SE', 'NW', 'SW', 'N', 'S', 'E', 'W', 'C', 'center'};
   default_pos = 'NE';
   [default_pos, args, ~] = parseoptarg(varargin, valid_positions, default_pos);

   % Get axis limits
   xlims = xlim();
   ylims = ylim();

   % Calculate range manually
   xrange = max(XData) - min(XData);
   yrange = max(YData) - min(YData);

   % Calculate thresholds for 'near edge' and 'near other points' which control
   % whether a point is moved so it does not overlap the edge or other points
   xedge_thresh = 0.1 * xrange;
   xoverlap_thresh = 0.1 * xrange;

   % Did not end up using y-versions
   % yedge_thresh = 0.1 * yrange;
   
   % Initialize label positions to 'NE'
   pos = repmat({default_pos}, size(XData));

   % The note below was followed by a commented out edge-overlap adjustment
   % section. I think I did that when developing exactremap demo, when the
   % labels were shifted around the edges. Instead I should have added an option
   % to control the threshold. I reactivated the edge overlap adjustment. Also,
   % only the right edge part was active, the left edge and "everywhere else"
   % sections were missing, but they were in another commented out block at the
   % very bottom, which was actually the original version of this function when
   % I only adjusted edges, not overlap. 
   
   % 9 Jul 2023, commented this out - not sure if this was ever used, but
   % occassionally it is nice to have the edges automatically moved e.g.
   % right edge would be 'E', left edge 'W', top 'N', bottom 'S', so this
   % could form the basis for that.
      
   % Adjust label positions if near edges
   for n = 1:length(XData)
      x = XData(n);
      y = YData(n);
      
      % Determine label position based on proximity to edge
      if x > xlims(2) - xedge_thresh % near right edge
         pos{n} = 'NW';
      elseif x < xlims(1) + xedge_thresh % near left edge
         pos{n} = 'NE';
      else % everywhere else
         pos{n} = 'NE';
      end
   end

   % Further adjust label positions to avoid overlap
   for n = 1:length(XData)
      for m = (n+1):length(XData)
         if ( abs(XData(n) - XData(m)) < xoverlap_thresh ) && ...
               ( abs(YData(n) - YData(m)) < xoverlap_thresh )
            if XData(n) < XData(m) % if point n is to the left of point m
               pos{n} = 'NW'; % to go up down: pos{n} = 'SE';
               pos{m} = 'NE';
            else % if point n is to the right of point m
               pos{n} = 'NE';
               pos{m} = 'NW'; % pos{m} = 'SE';
            end
         end
      end
   end

   % Apply labels
   for n = 1:length(XData)
      labelpoints(XData(n), YData(n), labels(n), pos{n}, 0.1, args{:});
   end
end
