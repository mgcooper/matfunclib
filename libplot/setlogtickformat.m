function setlogtickformat(varargin)
   %setlogtickformat Adjust log axes tick labels to display decimal numbers
   %
   %  setlogtickformat(ax, whichaxis, format_specifier)
   %
   % Inputs
   %  ax - Handle to the axes object
   %  whichaxis - 'x', 'y', or 'z'
   %
   % See also

   [ax, args] = parsegraphics(varargin{:});

   if isempty(ax)
      ax = gca;
   end

   [whichaxis, args, nargs] = parseoptarg(args, {'x', 'y', 'xy'}, 'xy');

   whichaxis = string(whichaxis);

   % Assume the remaining arg is the format specifier
   if nargs
      fspec = args{1};
   else
      fspec = '%.2f';
   end

   % Format the tick labels
   if whichaxis == "y" || whichaxis == "xy"

      yticks = get(ax, 'YTick');
      labels = arrayfun(@(y) num2str(y, fspec), yticks, 'UniformOutput', false);

      set(ax, 'YTickLabel', labels);
   end

   if whichaxis == "x" || whichaxis == "xy"

      xticks = get(ax, 'XTick');
      labels = arrayfun(@(x) num2str(x, fspec), xticks, 'UniformOutput', false);

      set(ax, 'XTickLabel', labels);
   end
end
