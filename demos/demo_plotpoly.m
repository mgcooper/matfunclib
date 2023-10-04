function varargout = demo_plotpoly(poly, varargin)

   % This is a useful demo of how to deal with adding new graphics to an
   % existing plot and/or dealing with user settings. For example, if the
   % 'FaceColor' property is set in varargin, this shows how to NOT override the
   % requested color, and if not, how to get the next color from 
   % matlab.graphics.chart.internal.nextstyle.
   
   % The reason I looked into this was to figure out why polyshapes look nicer
   % than whatever I perceive fill and patch to look like, but it must just be
   % the facealpha, 0.35 because this appears to just get the default color
   % order. The exception would be if the 'ax' that comes into this (from the
   % polyshape plot method) somehow has it's own custom colororder, b/c
   % matlab.graphics.chart.internal.nextstyle uses the ax object to get the
   % colors
   
   % UPDATE: see demo_polyshapeColorOrder. No special color order. 
   
   [ax, args] = axescheck(varargin{:});

   validateattributes(poly, {'polyshape'}, {}, mfilename, 'POLY', 1);

   args = matlab.graphics.internal.convertStringToCharArgs(args);

   nd = polyshape.checkArray(poly);

   axesParent =  isempty(ax) || isa(ax,'matlab.graphics.axis.AbstractAxes');
   if axesParent
      ax = newplot(ax);
   end

   % Determine if the face color is set. If so, skip it in the loop below.
   isFaceColorSet = any(cellfun(@(s) (ischar(s) || isstring(s)) && ...
      strncmpi(s, 'FaceColor', max(strlength(s), 1)), args(1:2:end)));

   %plot the polyshape
   H = gobjects(nd);
   for n = 1:numel(poly)
      nextColor = [0,0,0];
      if axesParent
         [~,nextColor,~] = matlab.graphics.chart.internal.nextstyle( ...
            ax, ~isFaceColorSet, false);
      end
      H(n) = matlab.graphics.primitive.Polygon('Shape',poly(n),...
         'FaceColor',nextColor,'FaceAlpha',0.35,...
         'Parent',ax, args{:});
   end

   if nargout > 0
      varargout{1} = H;
   end
end
