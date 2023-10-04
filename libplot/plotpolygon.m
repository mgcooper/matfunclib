function varargout = plotpolygon(P, PlotOpts)
   %PLOTPOLYGON Plot polyshape or polygon data.
   % 
   % plotpolygon(P)
   % H = plotpolygon(P)
   % H = plotpolygon(P, Name, Value)
   % 
   % See also: 
   arguments
      P
      PlotOpts.?matlab.graphics.primitive.Polygon
   end
   PlotOpts = namedargs2cell(PlotOpts);
   
   if isa(P,'polyshape')
      H = arrayfun(@(n) plot(P(n), PlotOpts{:}), 1:numel(P));
   elseif iscell(P)
      H = cellfun(@(x, y) plot(x, y, PlotOpts{:}), P(:, 1), P(:, 2));
   elseif ismatrix(P)
      H = plot(P(:, 1), P(:, 2), PlotOpts{:});
   end

   % For reference, if PX,PY cell arrays are passed in:
   % cellfun(@plot, PX, PY);

   if nargout == 1
      varargout{1} = H;
   end
end
