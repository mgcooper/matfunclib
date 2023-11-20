function rotatedText(xtxt, ytxt, txt, slope, props)
   %ADDROTATEDTEXT Adds rotated text label to various axis scales.
   %
   % Syntax:
   % addRotatedText(xtxt, ytxt, txt, slope, axpos, 'PropertyName', propertyValue, ...)
   %
   % Description:
   % This function adds a text label to a plot with specified rotation to match the given slope.
   % The function supports log-log, semilogx, semilogy, and linear scales.
   %
   % Inputs:
   % xtxt - The x-coordinate where the text is placed.
   % ytxt - The y-coordinate where the text is placed.
   % txt - The text string to be displayed.
   % slope - The slope of the text in data units.
   % axpos - The position of the axes object in the figure [left, bottom, width, height].
   %
   % PropertyName-PropertyValue pairs:
   % 'AxisType' - The type of axis scale: 'loglog', 'semilogx', 'semilogy', 'linear'.
   % 'FontSize' - The font size of the text.
   % 'Color' - The color of the text.
   % ... - Other text properties can be added as needed.
   %
   % Examples:
   % addRotatedText(10, 100, 'Sample Text', 45, get(gca,'Position'), 'AxisType', 'loglog', 'FontSize', 14)
   % addRotatedText(10, 100, 'Sample Text', 45, get(gca,'Position'), 'AxisType', 'linear', 'Color', 'red')
   %
   % See also: text, xlim, ylim, loglog, semilogx, semilogy, gca

   arguments
      xtxt
      ytxt
      txt
      slope
      props.?matlab.graphics.primitive.Text
   end

   % Set default props if user did not set them
   ResetFields = {'HorizontalAlignment', 'VerticalAlignment', 'FontSize', 'Color'};
   ResetValues = {'center', 'baseline', 12, [0.25, 0.25, 0.25]};
   for n = 1:numel(ResetFields)
      if ~ismember(ResetFields{n}, fieldnames(props))
         props.(ResetFields{n}) = ResetValues{n};
      end
   end

   % Get the text class defaults
   props = metaclassDefaults(props, ?matlab.graphics.primitive.Text);

   % Convert props to a varargin-like cell array
   props = namedargs2cell(props);

   ax = gca;
   axpos = plotboxpos(ax); % Get corrected axis position
   % axpos = get(ax, 'Position');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % NOTE: with this section active, the 
   % "if strcmp(get(ax,'DataAspectRatioMode'), 'manual')" section may not be
   % needed 
   % Change units to points for accurate dimension calculation
   fig = gcf;
   origFigUnits = fig.Units;
   origAxUnits = ax.Units;
   fig.Units = 'points';
   ax.Units = 'points';
   axpos = plotboxpos(ax); % Get corrected axis position

   % Restore original units
   fig.Units = origFigUnits;
   ax.Units = origAxUnits;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % Get the current axis limits, scales, and aspect ratio
   xlimits = xlim;
   ylimits = ylim;
   xlog = strcmp(get(ax, 'XScale'), 'log');
   ylog = strcmp(get(ax, 'YScale'), 'log');
   daspectRatio = daspect(ax);

   % Correct for aspect ratio using daspect if DataAspectRatioMode is manual
   if strcmp(get(ax, 'DataAspectRatioMode'), 'manual')
      xfactor = (xlimits(2) - xlimits(1)) / daspectRatio(1);
      yfactor = (ylimits(2) - ylimits(1)) / daspectRatio(2);
   else
      % For automatic aspect ratio, use axis position
      if xlog
         xfactor = axpos(3) / (log10(xlimits(2)) - log10(xlimits(1)));
      else
         xfactor = axpos(3) / (xlimits(2) - xlimits(1));
      end
      if ylog
         yfactor = axpos(4) / (log10(ylimits(2)) - log10(ylimits(1)));
      else
         yfactor = axpos(4) / (ylimits(2) - ylimits(1));
      end
   end

   % % This was the method that worked for linear, but I had to call this function
   % % once with empty text and then for real, so presumable it worked b/c the
   % % first ghost call set units to points, only kept this for now in case i need
   % % to remake the figure with the slopes printed and the method above fails.
   % % Note the key thing is this one doesn't reset the units to origUnits
   % if strcmp(get(ax, 'DataAspectRatioMode'), 'manual')
   %    yfactor = (ylimits(2) - ylimits(1)) / daspectRatio(2);
   %    xfactor = (xlimits(2) - xlimits(1)) / daspectRatio(1);
   % else
   %    % For automatic aspect ratio, we compensate using the physical dimensions
   %    fig = gcf;
   %    fig.Units = 'points';
   %    ax.Units = 'points';
   %    yfactor = axpos(4) / (ylimits(2) - ylimits(1));
   %    xfactor = axpos(3) / (xlimits(2) - xlimits(1));
   %    % Return the units to their original state if needed
   % end

   % Calculate the angle of rotation for the text
   txtangle = atand(slope * (yfactor / xfactor));

   % Add text to the plot
   text(ax, xtxt, ytxt, txt, 'rotation', txtangle, props{:});
end
