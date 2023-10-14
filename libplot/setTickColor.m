function h = setTickColor(palette, varargin)
   %SETTICKCOLOR Customizes tick label colors along an axis in a MATLAB figure.
   %
   % Syntax:
   %   h = setTickColor(palette)
   %   h = setTickColor(palette, ax)
   %   h = setTickColor(palette, ax, dim)
   %   h = setTickColor(_, Name, Value, ...)
   %
   % Description:
   %   This function sets the color of x or y tick labels in a MATLAB axis
   %   according to the given color palette. The palette must have at least as
   %   many colors as there are tick labels.
   %
   % Input Arguments:
   %   palette   - A matrix specifying RGB triplet color codes (default is
   %               colororder), or a valid color char/string/cellstr like 'r' or
   %               'red' or {'red', 'green'}. Dimensions should be Nx3, where N
   %               is the number of colors.
   %
   %   ax        - (Optional) Handle to the axes object where tick labels will
   %               be modified. If omitted, uses the current axes (gca).
   %
   %   dim       - (Optional) A single character, 'x' or 'y', specifying which
   %               axis should have its tick labels colored (default is 'x').
   %
   % Optional Name-Value Pair Arguments:
   %   Any valid name-value pair accepted by TEXT
   %
   % Output Arguments:
   %   h         - Array of text object handles for the new tick labels.
   %
   % Example Usage:
   %   h = setTickColor([1 0 0; 0 1 0; 0 0 1]);
   %   h = setTickColor([1 0 0; 0 1 0], gca);
   %   h = setTickColor('r', gca, 'y');
   %
   % Notes:
   %   - The function internally hides the original tick labels and creates
   %     new text objects for colored labels.
   %   - Ensure the palette has at least as many colors as tick labels.
   %
   % See also: text, gca, colororder

   if nargin < 1
      palette = colororder;
   else
      palette = parseplotcolors(palette);
   end

   % Parse graphics input
   [ax, args, ~, isfigure] = parsegraphics(varargin{:});

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end

   % Parse optional axes flag
   [dim, args] = parseoptarg(args, {'x', 'y', 'z'}, 'x');

   % Set axes-specific property names
   [TickProp, LabelProp, TickLabelProp, otherAxisLimits] = getProps(ax, dim);

   % Store original axes position b/c turning off the tick labels changes them
   axPosition = plotboxpos(ax);

   % Store original xlabel position
   labelHandle = get(ax, LabelProp);
   labelPosition = get(labelHandle, 'Position');

   % Store the original tick labels, tick values, and opposing axis limits
   tickLabels = get(ax, TickLabelProp);
   tickValues = get(ax, TickProp);

   % Create x/y positions for the new tick labels
   switch dim
      case 'x'
         xtickvals = tickValues;
         ytickvals = repmat(otherAxisLimits(1), numel(xtickvals), 1);
      case 'y'
         ytickvals = tickValues;
         xtickvals = repmat(otherAxisLimits(1), numel(ytickvals), 1);
   end

   % Nest the section that removes the current plot layout in a try-catch so it
   % can be reset to the original layout on error (see cleanfun)
   try
      % Hide original ax tick labels, then restore the original axes and axes
      % label position to make room for new labels.
      set(ax, TickLabelProp, []);
      set(labelHandle, 'Position', labelPosition);
      set(ax, 'Position', axPosition)

      % Create new tick labels with custom colors
      h = gobjects(length(tickValues), 1);
      for n = 1:length(tickValues)
         h(n) = text(ax, xtickvals(n), ytickvals(n), tickLabels{n}, 'Color', ...
            palette(n, :), 'VerticalAlignment', 'Top', 'HorizontalAlignment', ...
            'Center', args{:});
      end
   catch e
      % If the error occurred while setting the new tick lables, turn them off
      if exist('h', 'var') && any(ishandle(h))
         h = h(arrayfun(@ishandle, h));
         arrayfun(@(h) set(h, 'Visible', 'off'), h);
      end
      cleanfun(ax, axPosition, LabelProp, labelHandle, TickLabelProp, tickLabels);
      rethrow(e)
   end
end
%%
function cleanfun(ax, axPosition, LabelProp, labelHandle, TickLabelProp, tickLabels)
   set(ax, 'Position', axPosition, ...
      LabelProp, labelHandle, ...
      TickLabelProp, tickLabels)
end
%%
function [TickProp, LabelProp, TickLabelProp, otherAxisLimits] = getProps(ax, dim)
   if strcmp('x', dim)
      TickProp = 'XTick';
      LabelProp = 'XLabel';
      TickLabelProp = 'XTickLabel';
      otherAxisLimits = get(ax, 'YLim');
   else
      TickProp = 'YTick';
      LabelProp = 'YLabel';
      TickLabelProp = 'YTickLabel';
      otherAxisLimits = get(ax, 'XLim');
   end
end

%{
   Code graveyard

% Adjust properties for categorical ruler if necessary
% props = processCategoricalProps(ax, props);

% just in case it comes in handy, I used this to swap out the 'X' for 'Y'
% otherAxisLimits = get(ax, strrep(LimProp, upper(dim), upper(otherDim)));
% otherDim = 'y';
% LimProp = 'XLim';
% AxisProp = 'XAxis'; % only needed for processCategoricalProps
% otherDim = 'x';
% LimProp = 'YLim';
% AxisProp = 'YAxis';

%%
function TickValues = processCategoricalProps(ax, AxisProp)
   if iscategoricalaxes(ax, AxisProp)
      % It might not be necessary to convert categorical tick values since we
      % are just replacing the original ticks, if the axis is categorical we can
      % just send the original tickValues to the text function and they should
      % plot correctly, but keep these for reference:
      % tickValues = cat2double(tickValues);
      % might need num2ruler and/or ruler2num
      % tickValues = ruler2num
   end
end
%}
