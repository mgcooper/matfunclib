function varargout = formatPlotMarkers(varargin)
   %FORMATPLOTMARKERS Apply custom formatting to plot markers.
   %
   %    h = formatPlotMarkers()
   %    h = formatPlotMarkers('suppliedaxes', axesobject)
   %    h = formatPlotMarkers('suppliedline', lineobject)
   %    h = formatPlotMarkers(_, 'markersize', markersize)
   %    h = formatPlotMarkers(_, 'sparsefill', true)
   %    h = formatPlotMarkers(_, 'sparsefill', true, 'fillspacing', spacing)
   %    h = formatPlotMarkers(_, 'keepEdgeColor', true)
   %    h = formatPlotMarkers(_, 'keepFaceColor', true)
   %
   % Description:
   %
   %    H = FORMATPLOTMARKERS() applies default formatting to graphics objects
   %    which have markers. Use this to conveniently set aesthetically-pleasing
   %    formatting to markers.
   %
   %    H = FORMATPLOTMARKERS('SPARSEFILL', TRUE) reduces the density of
   %    plotted markers.
   %
   %    H = FORMATPLOTMARKERS('SPARSEFILL', TRUE, 'FILLSPACING') controls the
   %    number of points between markers.
   %
   %    H = SCATTERFILL('SUPPLIEDAXES', AXOBJ) control the axis to which the
   %    formatting is applied. Axobj is a matlab.graphics.axis.Axes object.
   %
   %    H = SCATTERFILL('SUPPLIEDLINE', LINEOBJ) control the specific line to
   %    which the formatting is applied. Lineobj is a handle to a plotted line.
   %
   % See also:

   % Parse inputs.
   [fillspacing, sparsefill, markersize, suppliedaxes, suppliedline, ...
      keepEdgeColor, keepFaceColor, args] = parseinputs(mfilename, varargin{:});

   % List graphics types which by default have no markers but should, or which
   % have markers (by default or not), but which should not be formatted.
   createMarkersTypeList = {'errorbar'};
   ignoreMarkersTypeList = {''};

   for m = numel(suppliedaxes):-1:1

      childrenWithMarkers = findChildrenWithMarkers(suppliedaxes{m}, ...
         suppliedline, ignoreMarkersTypeList, createMarkersTypeList);

      allChildrenWithMarkers{m} = childrenWithMarkers;

      if isempty(childrenWithMarkers)
         continue
      end

      for n = 1:numel(childrenWithMarkers)

         thisChild = childrenWithMarkers(n);

         numPoints = numel(get(thisChild, 'XData'));
         markerIdx = setMarkerIndices(numPoints, sparsefill, fillspacing);

         [markerColor, markerFaceColor, markerEdgeColor] = setMarkerColor(...
            thisChild, keepEdgeColor, keepFaceColor);

         applyFormatting(thisChild, markersize, markerColor, markerIdx, ...
            markerEdgeColor, markerFaceColor, args);
      end
   end
   if isscalar(allChildrenWithMarkers)
      allChildrenWithMarkers = vertcat(allChildrenWithMarkers{:});
   end
   [varargout{1:nargout}] = deal(allChildrenWithMarkers);
end

function childrenWithMarkers = findChildrenWithMarkers(thisaxes, suppliedline, ...
      ignoreMarkersTypeList, createMarkersTypeList)

   % Use the supplied axes unless a specific line was supplied
   if ~isobject(suppliedline) && isnan(suppliedline)
      Children = allchild(thisaxes);
   else
      Children = suppliedline;
   end

   % Loop through Children and find ones with markers. Use get instead of
   % dot indexing, because Octave graphics handles are numeric. Preallocate,
   % so an axes with no children returns an empty handle array.
   childrenWithMarkers = false(size(Children));
   for n = 1:numel(Children)
      child = Children(n);
      childType = get(child, 'Type');

      if ismember(childType, ignoreMarkersTypeList)
         continue
      end

      childrenWithMarkers(n) = isprop(child, 'Marker') ...
         && ~ismember('none', cellstr(get(child, 'Marker'))) ...
         || ismember(childType, createMarkersTypeList);
   end

   childrenWithMarkers = Children(childrenWithMarkers);
end

function midx = setMarkerIndices(numPoints, sparsefill, fillspacing)
   %SETMARKERINDICES Return the indices of the points that get a marker.
   %
   % The 'markersize' option sets the marker size for both branches.

   if sparsefill
      % Only fill some points.

      if isnan(fillspacing)
         % Set fillspacing such that 10 points are filled.
         fillspacing = max(1, numPoints/10); % if <10 points fill them all
      end
      numfill = fix(numPoints / fillspacing);
      midx = round(linspace(1, numPoints, numfill));
   else
      % Fill all points.
      midx = 1:numPoints;
   end
end

function [markerColor, markerFaceColor, markerEdgeColor] = setMarkerColor(...
      thisChild, keepEdgeColor, keepFaceColor)

   % Note: The most basic purpose of this function is to avoid setting
   % 'MarkerEdgeColor' to 'none' and 'MarkerFaceColor' to 'Color', since
   % that is almost always the desired behavior. These options allow for
   % keeping the edge color, while retaining the default behavior of no
   % edge color and a face color which matches the default 'Color'.

   % scatter has 'CData' instead of 'Color', but does have 'MarkerFaceColor' and
   % 'MarkerEdgeColor', and 'CData' could be mapped to data which has not been
   % tested.
   if isscatter(thisChild)
      markerColor = get(thisChild, 'CData');
   else
      markerColor = get(thisChild, 'Color');
   end
   if keepEdgeColor
      markerEdgeColor = get(thisChild, 'MarkerEdgeColor');
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
      markerFaceColor = get(thisChild, 'MarkerFaceColor');
   else
      markerFaceColor = markerColor;
   end
end

function applyFormatting(thisChild, markerSize, markerColor, markerIdx, ...
      markerEdgeColor, markerFaceColor, args)

   if iserrorbar(thisChild)
      % errorbar does not have 'MarkerIndices'

      % markerFaceColor prior defaults: [.7 .7 .7] and [.75 .75 1]

      set(thisChild,                               ...
         'Marker' ,              'o' ,             ...
         'MarkerSize',           markerSize,       ...
         'Color',                markerColor,      ...
         'MarkerEdgeColor',      [.2 .2 .2],       ...
         'MarkerFaceColor',      markerFaceColor,  ...
         'CapSize',              6,                ...
         args{:}                              );

   elseif isscatter(thisChild)

      set(thisChild,                               ...
         'SizeData',             markerSize^2,     ...
         'LineWidth',            1,                ...
         'MarkerEdgeColor',      markerEdgeColor,  ...
         'MarkerFaceColor',      markerFaceColor,  ...
         args{:}                              );
   else

      % Octave line objects have no 'MarkerIndices' property, so Octave
      % formats every marker.
      if isprop(thisChild, 'MarkerIndices')
         args = [{'MarkerIndices', markerIdx}, args];
      end
      set(thisChild,                               ...
         'MarkerSize',           markerSize,       ...
         'LineWidth',            1,                ...
         'MarkerEdgeColor',      markerEdgeColor,  ...
         'MarkerFaceColor',      markerFaceColor,  ...
         args{:}                              );
   end
end

function tf = isscatter(h)
   %ISSCATTER Return true if graphics object h is a scatter object.
   %
   % Compare the Type string, because MATLAB and Octave scatter objects have
   % different classes but the same 'scatter' Type.
   tf = strcmp(get(h, 'Type'), 'scatter');
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

   % Cast to a cell array for the main loop.
   suppliedaxes = arrayfun(@(ax) ax, suppliedaxes, 'UniformOutput', false);

   % Set sparsefill true if fillspacing has a non-default value.
   sparsefill = sparsefill || ~isnan(fillspacing);
end
