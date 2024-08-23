function h = formatPlotMarkers(varargin)
   %FORMATPLOTMARKERS Apply custom formatting to plot markers.
   %
   %  h = formatPlotMarkers(varargin)
   %
   % Description:
   %
   %  formatPlotMarkers provides a convenient method to set aesthetically
   %  pleasing plot formatting without cluttering code.
   %
   % Syntax:
   %  h = formatPlotMarkers() applies default formatting
   %  h = formatPlotMarkers('sparsefill', true) reduces the density of plotted
   %  markers.
   %  h = formatPlotMarkers('sparsefill', true, numPoints) controls the number
   %  of points.
   %  h = scatterfill('suppliedaxis',axobj) control the axis to which the
   %  formatting is applied. Axobj is a matlab.graphics.axis.Axes object.
   %  h = scatterfill('suppliedaxis',lineobj) control the specific line to which
   %  the formatting is applied. Lineobj is a handle to a plotted line.
   %
   % Note, the function checks in lineobj is in fact an axis and if so, treats
   % it as one instead.
   %
   % See also:

   % parse inputs
   [fillspacing, sparsefill, markersize, suppliedaxes, suppliedline, ...
      keepEdgeColor, keepFaceColor, args] = parseinputs(mfilename, varargin{:});

   % % rather than isobject, I could use this to check the line input handle:
   % if isa(suppliedline,'matlab.graphics.chart.primitive.Line')
   % end

   % set sparsefill true if fillspacing has a value to simplify the code.
   % this way either can be passed in, fillspacing, or sparsefill, where
   % sparsefill automatically fills every ten points.
   if ~isnan(fillspacing)
      sparsefill = true;
      if ischar(fillspacing)
         % just in case a string is somehow passed in by mistake
         fillspacing = str2double(fillspacing);
      end
   end

   numaxes = numel(suppliedaxes);
   numlineswithmarkers = 0;

   for m = 1:numaxes

      if numaxes == 1
         thisaxis = suppliedaxes;
      else
         thisaxis = suppliedaxes(m);
      end

      % use the supplied axis unless a specific line was supplied
      if ~isobject(suppliedline) && isnan(suppliedline)
         % there is either a supplied axis, or we assigned gca to it
         Children = allchild(thisaxis);  % get the children to find lines
      else
         Children = suppliedline;
      end

      % this should work for cases where Children comes up empty. EDIT,
      % previously I did not loop through Children. In simple cases, all the
      % lines with markers on an axis will be found, but in some cases, such
      % as with lsline, try will fail, and no lines with markers will be
      % found, so we loop through all the children and get ones with markers
      numchildren = numel(Children);
      linesWithMarkers = false(numchildren,1);
      for mm = 1:numchildren
         child = Children(mm);

         if child.Type == "bar" % add more types: || child.Type == ""
            % continue, leave linesWithMarkers(mm) = false;
            continue
         end

         % I think this is here in case a child has more than one line, but if
         % only one line per child, it would be sufficient to store the
         % true-false in linehasmarkers instead of the any() statement after
         % the try-catch
         try
            linehasmarkers = ~ismember({child.Marker},'none');
         catch
            try
               linehasmarkers = false(size({child.Marker}));
            catch % catch-all back up
               linehasmarkers = false;
            end
         end

         % May 2023 - if an errorbar is sent in without a marker, which is the
         % default case for errorbar, then this will catch it, but this is hacky
         if child.Type == "errorbar"
            linehasmarkers = true;
         end

         % I replaced the child(linehasmarkers) with the true-false, so now
         % linesWithMarkers is a tf in the loop, and after the loop it becomes
         % a container for the lines with markers
         linesWithMarkers(mm) = any(linehasmarkers);
         % linesWithMarkers = child(linehasmarkers);
         numlineswithmarkers = numlineswithmarkers + sum(linehasmarkers);
      end

      linesWithMarkers = Children(linesWithMarkers);

      if isempty(linesWithMarkers)
         continue
      end


      for n = 1:numel(linesWithMarkers)

         thisLine = linesWithMarkers(n);

         wasscatter = isa(thisLine,'matlab.graphics.chart.primitive.Scatter');
         if wasscatter
            % More complicated b/c of potential for 'CData' property. Does not
            % have 'Color' property, does have MarkerFaceColor/EdgeColor. With
            % new refactoring below, no longer necessary to continue, but have
            % not tested with CData mapped to data yet.
            % continue
         end

         numPoints = numel(thisLine.XData);

         if sparsefill
            % only fill some points, use larger symbol size

            % if not provided, set fillspacing such that 10 points are filled
            if isnan(fillspacing)
               fillspacing = max(1, numPoints/10); % if <10 points fill them all
            end
            numfill = fix(numPoints/fillspacing);
            markerIdx = round(linspace(1,numPoints,numfill),0);
         else
            % fill all points, use smaller symbol size
            markerIdx = 1:numPoints;
            markerSz = 6;
         end

         % Note: The most basic purpose of this function is to avoid setting
         % 'MarkerEdgeColor' to 'none' and 'MarkerFaceColor' to 'Color', since
         % that is almost always the desired behavior. These options allow for
         % keeping the edge color, while retaining the default behavior of no
         % edge color and a face color which matches the default 'Color'.
         if wasscatter
            markerColor = thisLine.CData;
         else
            markerColor = thisLine.Color;
         end
         if keepEdgeColor
            markerEdgeColor = thisLine.MarkerEdgeColor;
            if ~isnumeric(markerEdgeColor) ...
                  && ismember(markerEdgeColor, {'none', 'auto'})
               % Undocumented method to set preferred default markerEdgeColor
               % by setting 'keepEdgeColor' true. This works b/c the default is
               % 'none' i.e., if MarkerEdgeColor has not been set, it will be
               % 'none', and this will set it.
               markerEdgeColor = [.3 .3 .3];
            end
         else
            markerEdgeColor = 'none';
         end
         if keepFaceColor
            markerFaceColor = thisLine.MarkerFaceColor;
         else
            markerFaceColor = markerColor;
         end

         % errorbar doesn't have 'MarkerIndices'
         if iserrorbar(thisLine)
            set(thisLine,                                ...
               'Marker' ,              'o' ,             ...
               'MarkerSize',           markersize,       ...
               'Color',                markerColor,      ...
               'MarkerEdgeColor',      [.2 .2 .2],       ...
               ... 'MarkerFaceColor',      markerFaceColor,  ...
               'MarkerFaceColor',      [.7 .7 .7],       ... [.75 .75 1]
               'CapSize',              6,                ...
               args{:}                              );

         elseif wasscatter
            set(thisLine,                                ...
               'SizeData',             markersize^2,     ...
               'LineWidth',            1,                ...
               'MarkerEdgeColor',      markerEdgeColor,  ...
               'MarkerFaceColor',      markerFaceColor,  ...
               args{:}                              );
         else
            set(thisLine,                                ...
               'MarkerIndices',        markerIdx,        ...
               'MarkerSize',           markersize,       ...
               'LineWidth',            1,                ...
               'MarkerEdgeColor',      markerEdgeColor,  ...
               'MarkerFaceColor',      markerFaceColor,  ...
               args{:}                              );
         end
      end

   end

   if numlineswithmarkers == 0
      h = [];
      disp('no lines with markers found')
      return;
   end
end

function [fillspacing, sparsefill, markersize, suppliedaxes, suppliedline, ...
      keepEdgeColor, keepFaceColor, varargs] = parseinputs(funcname, varargin)


   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   %addParameter(parser, 'markerfacecolor', 'none', @ischar);
   addParameter(parser, 'fillspacing', nan, @isnumericscalar);
   addParameter(parser, 'sparsefill', false, @islogicalscalar);
   addParameter(parser, 'markersize', 10, @isnumericscalar);
   addParameter(parser, 'suppliedaxes', gca, @isaxis);
   addParameter(parser, 'suppliedline', nan, @isobject);
   addParameter(parser, 'keepEdgeColor', false, @islogicalscalar);
   addParameter(parser, 'keepFaceColor', false, @islogicalscalar);

   parse(parser, varargin{:});

   %markerfacecolor   = rbg(p.Results.markerfacecolor);
   fillspacing    = parser.Results.fillspacing;
   sparsefill     = parser.Results.sparsefill;
   markersize     = parser.Results.markersize;
   suppliedaxes   = parser.Results.suppliedaxes;
   suppliedline   = parser.Results.suppliedline;
   keepEdgeColor  = parser.Results.keepEdgeColor;
   keepFaceColor  = parser.Results.keepFaceColor;
   unmatched      = parser.Unmatched;

   % convert unmatched to varargin
   varargs = namedargs2cell(unmatched);

   % for reference, could use these to validate suppliedline
   % if isa(linesWithMarkers,'matlab.graphics.primitive.Line.Type')

   % but there are others, and I am not sure of them all:
   % if isa(linesWithMarkers,'matlab.graphics.chart.primitive.Line.Type')
   % if isa(linesWithMarkers,'matlab.graphics.function.FunctionLine.Type')
   % if isa(linesWithMarkers,'matlab.graphics.function.ImplicitFunctionLine.Type')
   % if isa(linesWithMarkers,'matlab.graphics.function.ParameterizedFunctionLine.Type')
   % if isa(linesWithMarkers,'matlab.graphics.chart.decoration.ConstantLine.Type')
end
