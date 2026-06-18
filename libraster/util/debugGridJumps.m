function debugGridJumps(X, Y)
   %DEBUGGRIDJUMPS Scatter a grid and highlight where its spacing is non-uniform.
   %
   %  debugGridJumps(X, Y) plots the grid nodes and overlays the nodes where the
   %  X or Y spacing JUMPS (deviates from the modal cell size).
   %
   %  Development aid for diagnosing the borderline uniform-vs-irregular case: a
   %  grid that is mostly uniform but has a few non-modal cell-size diffs, as
   %  arises from irregular / projected geometry or a gappy (non-full) grid with
   %  missing rows or columns. Use it to SEE where the breaks are when deciding
   %  why mapGridCellSize / customIsUniform / checkuniformity classify a grid the
   %  way they do. (This was the scratchpad that originally led to checkuniformity;
   %  the relative-tolerance customIsUniform handles float NOISE, but a few genuine
   %  jumps -- e.g. matfunclib-5c1 gappy grids -- still land here.)
   %
   % Example
   %   x = [0 10 20 30 50 60];   % a jump between 30 and 50
   %   [X, Y] = meshgrid(x, 0:10:40);
   %   debugGridJumps(X, Y)
   %
   % See also: mapGridCellSize, customIsUniform, mapGridInfo, findjumps

   xu = unique(X(:));
   yu = unique(Y(:));
   xji = findjumps(xu);
   yji = findjumps(yu);

   xjump = ismember(X(:), xu(xji));
   yjump = ismember(Y(:), yu(yji));

   figure;
   scatter(X(:), Y(:), 20, [0.7 0.7 0.7], 'filled'); hold on
   hx = scatter(X(xjump), Y(xjump), 40, 'b', 'filled');
   hy = scatter(X(yjump), Y(yjump), 40, 'r', 'filled');
   xlabel('X'); ylabel('Y'); axis equal
   legend([hx, hy], {'X-spacing jump', 'Y-spacing jump'}, 'Location', 'best')
   title(sprintf('%d X-jumps, %d Y-jumps  (%d x %d unique nodes)', ...
      numel(xji), numel(yji), numel(xu), numel(yu)))
end
