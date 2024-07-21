function varargout = plotpolygon(P, PlotOpts)
   %PLOTPOLYGON Plot polyshape or polygon data.
   %
   %  plotpolygon(P)
   %  H = plotpolygon(P)
   %  H = plotpolygon(P, Name, Value)
   %
   % Note: this function assumes P is a polyshape or an object containing
   % polyshapes (e.g. an array or cell array of polyshapes).
   %
   % See also: mkpolyshape

   arguments
      P
      PlotOpts.?matlab.graphics.primitive.Polygon
   end
   PlotOpts = namedargs2cell(PlotOpts);

   hold on

   if iscell(P) && all(all(cellfun(@(p) isa(p, 'polyshape'), P)))
      P = [P{:}];
   end

   if isa(P, 'polyshape')
      % Remove empty polyshapes
      keep = arrayfun(@(n) ~isempty(P(n).Vertices), 1:numel(P));
      P = P(keep);
      H = plot(P, PlotOpts{:});
      % H = arrayfun(@(n) plot(P(n), PlotOpts{:}), 1:numel(P));

   elseif iscell(P)

      if isvector(P)
         H = cellfun(@(p) plot(p(:, 1), p(:, 2), PlotOpts{:}), P);

      elseif ismatrix(P)
         H = cellfun(@(x, y) plot(x, y, PlotOpts{:}), P(:, 1), P(:, 2));
      end

   elseif ismatrix(P)
      H = plot(P(:, 1), P(:, 2), PlotOpts{:});
   end

   if nargout == 1
      varargout{1} = H;
   end
end
