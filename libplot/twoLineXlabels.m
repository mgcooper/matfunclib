function twoLineXlabels(ax, xlabels, jitter, varargin)
   %TWOLINEXLABELS Create x axis labels that span two lines
   %
   % twoLineXlabels(ax, xlabels, jitter, varargin) where varargin is any input
   % accepted by built-in function 'text'.
   %
   % See also:

   % See setcolorbar for example how to do this for colorbar tick labels.

   % Get the number of rows and columns in the xlabels array
   [rows, cols] = size(xlabels);

   % Get the current xticks to set the x coordinate of the new two-line labels
   xTicks = get(ax, 'XTick');

   % Define the y coordinate of the new two-line labels
   yLims = get(ax, 'YLim');
   yCoord = yLims(1) + jitter;

   % Define function to compose the label
   Fprint = @(label) sprintf('%s\n%s\n', label);

   set(ax,'XTickLabel','');
   for n = 1:max([rows; cols])
      text(xTicks(n), yCoord, Fprint(xlabels(:, n)), 'HorizontalAlignment', ...
         'center', 'VerticalAlignment', 'middle', varargin{:})
   end

   % Earlier version used strtrim:
   % Fprint = @(label) strtrim(sprintf('%s\n%s\n', label));
   %
   % Also, VerticalAlignment was 'cap', maybe needed if strtrim is used.
   %
   % Should also works with a cellstr array:
   % Fprint = strtrim(sprintf('%s\\newline%s\\newline%s\n', labelArray{:}))
end
