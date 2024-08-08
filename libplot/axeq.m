function axeq(ax)
   %axeq Sets x and y axis limits to be identical
   %
   %  Syntax:
   %    axeq(ax)
   %
   %  Input:
   %    ax: (optional) Axis handle. If not provided, uses current axes.
   %
   % See also:

   % Use current axes if no axis handle is provided
   if nargin < 1 || isempty(ax)
      ax = gca;
   end

   % Get current x and y limits
   xlims = xlim(ax);
   ylims = ylim(ax);

   % Find the overall min and max
   minVal = min([xlims(1), ylims(1)]);
   maxVal = max([xlims(2), ylims(2)]);

   % Set both x and y limits to this range
   xlim(ax, [minVal, maxVal]);
   ylim(ax, [minVal, maxVal]);

   % Optionally, make the axis square to ensure equal scaling
   axis(ax, 'square');
end
