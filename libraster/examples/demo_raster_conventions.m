%% Raster conventions demo: centers vs edges vs postings vs "image"
% A faithful, paneled re-creation of the original cells-vs-postings study
% (offboarding testbed/rasterref/test): test_cells_vs_postings.m (the plotter and
% reference comparison + ltln2val transect), test_cells_vs_postings_v2.m (the
% cells/postings/"warp" bounding-box comparison -> the reference-box panels in
% section 3), test_notes.m (the relative grid-spacing tolerance, now in
% customIsUniform), and readme.m (the orientation/rotation limitation). It shows
% how MATLAB's referencing and plotting functions disagree about whether grid
% coordinates are
% cell CENTERS, cell EDGES, or point POSTINGS, and how libraster/rasterref
% canonicalizes on centers. Every figure is paneled (<= 4 tiles) for side-by-side
% comparison, and uses the original's fixed axis limits + cell-edge minor ticks +
% green reference box + value labels so the half-cell offsets are visible.
%
% Figures:
%   0. The core bug, in numbers (centers fed to a cells reference)
%   1. Base plotters on raw (LAT,LON): surface / texturemap / pcolor / imagesc
%   2. Referenced display on ONE cells reference: grid2image / geoshow surface /
%      geoshow texturemap / rastersurf  (surface interpolates; the rest are crisp)
%   3. Cells vs Postings reference: the half-cell offset (display VIA the R)
%   4. Quantitative proof: geointerp transect at lat = 0
%   5. libraster display helpers (plotraster, rastersurf, rastercontour, transparent)
%   6. Real data: the bundled example_*.tif round-trip on the libraster tools
%
% See also: ../README.md, ../docs/raster-conventions-journey.md, rastersurf,
% plotraster, rastercontour, rasterref, gridNodesToEdges
%
% Matt Cooper, https://github.com/mgcooper

% Start from a clean slate so the paneled layouts are robust to any figures the
% user already has open (a stale figure can otherwise steal a tile).
close all

hasMap = license('test', 'map_toolbox') == 1;

%% Shared data (the original's small labeled grid)
Z = reshape(1:16, 4, 4).';        % [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16]
lon = [0 30 60 90];
lat = [30 0 -30 -60];
[LON, LAT] = meshgrid(lon, lat);
cellsize = 30; halfcell = cellsize / 2;
cmap = autumn(64);

% References: MATLAB built-ins (limits = cell edges / postings) and rasterref
% (treats LON,LAT as cell centers and pads the limits outward half a cell).
if hasMap
   Rcell_ml = georefcells([-60 30], [0 90], size(Z), 'ColumnsStartFrom', 'north');
   Rpost_ml = georefpostings([-60 30], [0 90], size(Z), 'ColumnsStartFrom', 'north');
   Rcell = rasterref(LON, LAT, 'cells', 'silent', true);     % positional form
   Rpost = rasterref(LON, LAT, 'postings', 'silent', true);
end

%% 0. Feeding centroids to a "cells" reference: the core bug (in numbers)
xs = 0:10:100; ys = 50:-10:0;
[Xs, Ys] = meshgrid(xs, ys);
Rcorrect = rasterref(Xs, Ys, 'UseGeoCoords', false, 'silent', true);
Rwrong = maprefcells([min(xs) max(xs)], [min(ys) max(ys)], size(Xs), ...
   'ColumnsStartFrom', 'north', 'RowsStartFrom', 'west');
fprintf('\n-- cell size (true = 10) --\n');
fprintf('  rasterref (centers, correct):   %.4g\n', Rcorrect.CellExtentInWorldX);
fprintf('  raw maprefcells (edges, wrong): %.4g\n', Rwrong.CellExtentInWorldX);

%% 1. Base plotters on raw (LAT,LON) coordinates (2x2)
% How each plotter interprets the SAME LAT,LON,Z with no reference object.
figure('Name', '1. Base plotters on raw (LAT,LON)', 'Colormap', cmap);
tiledlayout(2, 2);

if hasMap
   nexttile;
   g = geoshow(LAT, LON, Z, 'DisplayType', 'surface'); g.ZData = zeros(size(Z));
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
   title({'geoshow surface', 'values at cell CORNERS; last row/col dropped'});

   nexttile;
   g = geoshow(LAT, LON, Z, 'DisplayType', 'texturemap'); g.ZData = zeros(size(Z));
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
   title({'geoshow texturemap', 'squeezed into the LAT/LON limits'});
else
   nexttile; text(.1, .5, 'geoshow needs Mapping Toolbox'); axis off
   nexttile; text(.1, .5, 'geoshow needs Mapping Toolbox'); axis off
end

nexttile;
pcolor(LON, LAT, Z); shading flat
styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
title({'pcolor(LON,LAT,Z)', 'coords are cell EDGES; drops last row/col'});

nexttile;
imagesc(unique(LON), unique(LAT), Z); set(gca, 'YDir', 'normal');
styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
title({'imagesc(lon,lat,Z)', 'coords are cell CENTERS'});

%% 2. Referenced display on ONE cells reference (2x2)
% Same data + same cells reference, four display paths. 'surface' interpolates
% and drops a row/col; grid2image / geoshow texturemap / rastersurf draw crisp,
% correctly-centered cells.
if hasMap
   figure('Name', '2. Referenced display (cells reference)', 'Colormap', cmap);
   tiledlayout(2, 2);

   nexttile;
   grid2image(Z, Rcell); hold on; plotRefBox(gca, Rcell);
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z); title('grid2image(Z, Rcells)');

   nexttile;
   geoshow(Z, Rcell, 'DisplayType', 'surface', 'ZData', zeros(size(Z)), 'CData', Z);
   hold on; plotRefBox(gca, Rcell);
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
   title({'geoshow surface', '(interpolated, offset)'});

   nexttile;
   geoshow(Z, Rcell, 'DisplayType', 'texturemap', 'ZData', zeros(size(Z)), 'CData', Z);
   hold on; plotRefBox(gca, Rcell);
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
   title({'geoshow texturemap', '(crisp cells)'});

   nexttile;
   rastersurf(Z, Rcell); hold on; plotRefBox(gca, Rcell);
   styleRefAxes(gca); labelZ(gca, LON, LAT, Z);
   title({'rastersurf(Z, Rcells)', '(crisp, via geoshow texturemap)'});
end

%% 3. Cells vs Postings reference: the half-cell offset (1x2)
% Display VIA the reference (geoshow(Z,R)) -- NOT geoshow(LAT,LON,Z) -- so the
% colored cells actually move. Red dots are the (lon,lat) samples: under 'cells'
% they sit at cell CENTERS (green box pads half a cell beyond them); under
% 'postings' they sit at the grid NODES (green box hugs the outer samples). With
% identical axis limits the colored extents and boxes differ -- they are NOT the
% same picture.
if hasMap
   figure('Name', '3. Cells vs Postings (display via R)', 'Colormap', cmap);
   tiledlayout(1, 2);

   nexttile;
   geoshow(Z, Rcell, 'DisplayType', 'surface', 'ZData', zeros(size(Z)), 'CData', Z);
   hold on; plotRefBox(gca, Rcell);
   plot(LON(:), LAT(:), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
   styleRefAxes(gca);
   title({'rasterref ''cells''', 'box pads half a cell past samples'});

   nexttile;
   geoshow(Z, Rpost, 'DisplayType', 'surface', 'ZData', zeros(size(Z)), 'CData', Z);
   hold on; plotRefBox(gca, Rpost);
   plot(LON(:), LAT(:), 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
   styleRefAxes(gca);
   title({'rasterref ''posting''', 'box hugs the outer samples'});
end

%% 4. Quantitative proof: geointerp transect at lat = 0 (1 axes)
% Sample each reference along a W-E transect through row 2 (values 5 6 7 8) and
% compare to the correct nearest-cell answer. The reference whose steps line up
% with the dashed "correct" curve is interpreting the grid as centers correctly.
if hasMap
   lonq = -16:1:106;
   latq = zeros(size(lonq));
   refs = {Rcell_ml, Rcell, Rpost_ml, Rpost};
   names = {'MATLAB cells', 'rasterref cells', 'MATLAB postings', 'rasterref postings'};
   % geointerp is the modern replacement for the (removed) ltln2val.
   vals = nan(numel(refs), numel(lonq));
   for r = 1:numel(refs)
      vals(r, :) = geointerp(Z, refs{r}, latq, lonq, 'nearest');
   end
   % correct nearest-cell answer: edges at -15 15 45 75 105 -> values 5 6 7 8
   edges = [-15 15 45 75 105]; stepvals = [5 6 7 8];
   correct = nan(size(lonq));
   for k = 1:4
      correct(lonq >= edges(k) & lonq < edges(k + 1)) = stepvals(k);
   end

   figure('Name', '4. geointerp transect (lat = 0)');
   plot(lonq, correct, 'k--', 'LineWidth', 3, 'DisplayName', 'correct'); hold on
   co = lines(numel(refs));
   for r = 1:numel(refs)
      plot(lonq, vals(r, :), '-', 'LineWidth', 1.5, 'Color', co(r, :), ...
         'DisplayName', names{r});
   end
   xline([0 30 60 90], ':', 'Color', [.6 .6 .6], 'HandleVisibility', 'off');
   xlabel('Longitude'); ylabel('geointerp (nearest)'); ylim([4 9]);
   legend('Location', 'southoutside', 'Orientation', 'horizontal', 'NumColumns', 3);
   title({'Nearest-cell value along lat = 0', ...
      'rasterref tracks "correct"; MATLAB cells is offset half a cell'});
end

%% 5. libraster display helpers, consistent data (2x2)
% All four panels use the SAME labeled grid + cells reference, so differences are
% the function's doing, not the data's. The last panel blanks two interior cells
% (6 and 11) to show that 'transparent' makes ONLY NaN cells see-through.
% Each panel is wrapped so that if one display wrapper misbehaves when composed
% in a tiledlayout, the others (and the 2x2 layout) still render.
if hasMap
   figure('Name', '5. libraster display helpers', 'Colormap', cmap);
   tiledlayout(2, 2);

   nexttile;
   try
      plotraster(Z, Rcell); labelZ(gca, LON, LAT, Z); styleRefAxes(gca);
   catch ME
      showPanelError(ME);
   end
   title('plotraster(Z, Rcells)', 'Interpreter', 'none');

   nexttile;
   try
      rastersurf(Z, Rcell); labelZ(gca, LON, LAT, Z); styleRefAxes(gca);
   catch ME
      showPanelError(ME);
   end
   title('rastersurf(Z, Rcells)', 'Interpreter', 'none');

   nexttile;
   try
      rastercontour(Z, Rcell); styleRefAxes(gca);
   catch ME
      showPanelError(ME);
   end
   title('rastercontour(Z, Rcells)', 'Interpreter', 'none');

   nexttile;
   Zt = Z; Zt(Z == 6 | Z == 11) = NaN;     % blank two interior cells
   try
      rastersurf(Zt, Rcell, 'transparent'); labelZ(gca, LON, LAT, Z); styleRefAxes(gca);
   catch ME
      showPanelError(ME);
   end
   title({'rastersurf(..., ''transparent'')', 'only cells 6 & 11 are transparent'}, ...
      'Interpreter', 'none');
end

%% 6. Real data: the bundled example_*.tif round-trip (2x2)
% example_cells.tif and example_postings.tif hold the SAME AOD grid written with
% a cells vs a postings reference and read back; example_post2cells.tif is the
% postings grid reinterpreted as cells. GeoTIFF only stores pixel-is-area vs
% pixel-is-point, so the read-back R class is whatever the file encodes -- the
% reason example_post2cells.tif exists. The panels exercise the libraster display
% tools on real data; the printout shows each file's recovered reference.
if hasMap && ~isempty(which('example_cells.tif'))
   [Zc, Rc] = readgeoraster('example_cells.tif');
   [Zp, Rp] = readgeoraster('example_postings.tif');
   Zc = double(Zc); Zp = double(Zp);

   fprintf('\n-- example_*.tif recovered references (geotiff round-trip) --\n');
   fprintf('  example_cells.tif    -> %s, lon [%.3f %.3f]\n', ...
      class(Rc), Rc.LongitudeLimits);
   fprintf('  example_postings.tif -> %s, lon [%.3f %.3f]\n', ...
      class(Rp), Rp.LongitudeLimits);

   figure('Name', '6. Real data: example_*.tif', 'Colormap', cmap);
   tiledlayout(2, 2);

   nexttile;
   try
      plotraster(Zc, Rc); set(gca, 'XTickMode', 'auto', 'YTickMode', 'auto');
   catch ME
      showPanelError(ME);
   end
   title('plotraster(example\_cells.tif)');

   nexttile;
   try
      plotraster(Zp, Rp); set(gca, 'XTickMode', 'auto', 'YTickMode', 'auto');
   catch ME
      showPanelError(ME);
   end
   title('plotraster(example\_postings.tif)');

   nexttile;
   try
      rastersurf(Zc, Rc);
   catch ME
      showPanelError(ME);
   end
   title('rastersurf(example\_cells.tif)');

   nexttile;
   try
      rastercontour(Zc, Rc);
   catch ME
      showPanelError(ME);
   end
   title('rastercontour(example\_cells.tif)');
end

%% local helpers
function styleRefAxes(ax)
   % The original's fixed limits, ticks at sample points, minor ticks at cell
   % edges, and equal aspect -- so half-cell offsets are legible.
   axis(ax, 'image');
   set(ax, 'XLim', [-15 105], 'YLim', [-75 45], ...
      'XTick', [0 30 60 90], 'YTick', [-60 -30 0 30], ...
      'TickDir', 'out', 'Box', 'on');
   ax.XAxis.MinorTick = 'on'; ax.YAxis.MinorTick = 'on';
   ax.XAxis.MinorTickValues = [-15 15 45 75 105];
   ax.YAxis.MinorTickValues = [-75 -45 -15 15 45];
end

function labelZ(ax, LON, LAT, Z)
   % Print each cell value at its (lon,lat) sample point.
   hold(ax, 'on');
   text(ax, LON(:), LAT(:), num2str(Z(:)), 'Color', 'b', ...
      'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

function plotRefBox(ax, R)
   % Outline the outer limits of a raster reference (its cell-edge extent).
   if strcmp(R.CoordinateSystemType, 'geographic')
      xl = R.LongitudeLimits; yl = R.LatitudeLimits;
   else
      xl = R.XWorldLimits; yl = R.YWorldLimits;
   end
   plot(ax, xl([1 2 2 1 1]), yl([1 1 2 2 1]), 'g-', 'LineWidth', 2);
end

function showPanelError(ME)
   % Graceful degradation: if a panel's display wrapper fails, blank the tile and
   % print the error so the rest of the figure (and the layout) still renders.
   ax = gca;
   cla(ax, 'reset'); axis(ax, 'off');
   text(ax, 0.5, 0.5, sprintf('panel unavailable:\n%s', ME.message), ...
      'Units', 'normalized', 'HorizontalAlignment', 'center', ...
      'VerticalAlignment', 'middle', 'Color', [0.6 0 0], 'Interpreter', 'none');
end
