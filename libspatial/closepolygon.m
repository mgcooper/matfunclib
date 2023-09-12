function [Xclosed, Yclosed] = closepolygon(X, Y)
   %CLOSEPOLYGON Close single or multi-part polygon.
   %
   %  [Xclosed, Yclosed] = closepolygon(X, Y) Closes the polygon defined by
   %  vertices X, Y, such that the first and last vertex of each polygon are
   %  identical.
   %
   % See also: 

   arguments
      X (:,:) {mustBeNumeric}
      Y (:,:) {mustBeNumeric}
   end

   % Keep track of whether the last index is nan
   lastindnan = isnan(X(end));
   wascolumns = iscolumn(X);
   
   % First, identify if there are multiple parts separated by nan's.
   [S, E, L] = nonnansegments({X, Y});

   % Require X and Y have identical nan-delimited segments.
   assert(all(cellfun(@(s) isequal(S{1}, s), S)))
   assert(all(cellfun(@(e) isequal(E{1}, e), E)))

   % Use the indices found on X, since they are identical to Y
   S = S{1};
   E = E{1};
   L = L{1};
   
   % Put the polygon parts into a cell array
   Xc = arrayfun(@(s, e) X(s:e), S, E, 'un', 0);
   Yc = arrayfun(@(s, e) Y(s:e), S, E, 'un', 0);

   % Function to find open polygons
   isopen = @(xs, ys, xe, ye) (xs ~= xe) || (ys ~= ye);
   closex = @(x) [x(:); x(1)];
   closey = @(y) [y(:); y(1)];

   % Cycle each part and close it
   Iopen = find(arrayfun(@(s, e) isopen(X(s), Y(s), X(e), Y(e)), S, E));
   
   for i = Iopen(:)'
      Xc{i} = closex(Xc{i});
      Yc{i} = closey(Yc{i});
   end
   
   % Return as a nan-separated list
   Xclosed = [];
   Yclosed = [];
   for n = 1:numel(Xc)
      Xclosed = [Xclosed; Xc{n}; nan]; %#ok<*AGROW> 
      Yclosed = [Yclosed; Yc{n}; nan];
   end
   
   % Remove the trailing nan unless it exists in the input
   if ~lastindnan
      Xclosed = Xclosed(1:end-1);
      Yclosed = Yclosed(1:end-1);
   end
   
   % Return rows if the inputs were rows
   if ~wascolumns
      Xclosed = Xclosed(:)';
      Yclosed = Yclosed(:)';
   end
end
