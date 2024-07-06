function setlogtickformat(ax, whichaxis)
   %setlogtickformat Adjust log axes tick labels to display decimal numbers
   %
   %  setlogtickformat(ax, whichaxis)
   %
   % Inputs
   %  ax - Handle to the axes object
   %  whichaxis - 'x', 'y', or 'z'
   %
   % See also

   if nargin < 1
      ax = gca;
   end
   if nargin < 2
      whichaxis = 'xy';
   end

   if string(whichaxis) == "y" || string(whichaxis) == "xy"

      yticks = get(gca, 'YTick');
      ytick_labels = arrayfun(@(y) num2str(y, '%.2f'), yticks, 'UniformOutput', false);
      set(gca, 'YTickLabel', ytick_labels);
   end

   if string(whichaxis) == "x" || string(whichaxis) == "xy"

      xticks = get(gca, 'XTick');
      xtick_labels = arrayfun(@(x) num2str(x, '%.2f'), xticks, 'UniformOutput', false);
      set(gca, 'XTickLabel', xtick_labels);
   end
end
