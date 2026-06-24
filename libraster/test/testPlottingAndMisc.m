classdef testPlottingAndMisc < matlab.unittest.TestCase
   %TESTPLOTTINGANDMISC Smoke tests for libraster plotting / IO / misc utilities.
   %
   % Covers the util/ plotting and misc helpers that had NO test coverage:
   % coverlay, plotMapGrid, plotRbox, patchRbox, plot_continents, contourLegend,
   % debugGridJumps, mapbox, geobox, rotatexy, parseMapProjection,
   % get_inset_coords, arcgridwrite2, copygeoprjtemplate, getlatlonticks.
   %
   % These are mostly PLOTTING or IO functions, so the goal is SMOKE testing: the
   % function RUNS without error on valid input and returns/produces the right
   % type or a valid handle -- NOT visual correctness. Computational helpers
   % (rotatexy, mapbox, geobox, get_inset_coords, parseMapProjection) assert real
   % outputs. Functions that genuinely cannot run headless are FILTERED with
   % assumeFail/assumeTrue rather than failing.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Static)
      function [X, Y] = planarGridVectors()
         X = 0:10:100;
         Y = 50:-10:0;
      end
      function [X, Y, Z] = planarGridArrays()
         x = linspace(0, 100, 11);
         y = linspace(50, 0, 6);
         [X, Y] = meshgrid(x, y);
         % Z over the same domain (size matches X/Y: 6 rows x 11 cols).
         Z = sin(X / 20) + cos(Y / 15);
      end
      function R = planarR()
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
      end
      function R = geoR()
         [X, Y] = meshgrid(-50:0.5:-40, 60:-0.5:50);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true);
      end
      function hasMap = mapToolbox()
         hasMap = license('test', 'map_toolbox') == 1;
      end
   end

   methods (Test)

      % ---- rotatexy (pure compute) ----
      function testRotatexyNinetyDegrees(testCase)
         % Rotating (1,0) by 90 degrees CCW gives (0,1).
         [xr, yr] = rotatexy(1, 0, 90);
         testCase.verifyEqual(xr, 0, 'AbsTol', 1e-12);
         testCase.verifyEqual(yr, 1, 'AbsTol', 1e-12);
      end
      function testRotatexyZeroIdentity(testCase)
         [xr, yr] = rotatexy(3, -4, 0);
         testCase.verifyEqual(xr, 3, 'AbsTol', 1e-12);
         testCase.verifyEqual(yr, -4, 'AbsTol', 1e-12);
      end

      % ---- mapbox (build a box) ----
      function testMapboxReturnsCoords(testCase)
         [xrect, yrect] = mapbox([0 10], [0 5]);
         testCase.verifyEqual(numel(xrect), 5);
         testCase.verifyEqual(numel(yrect), 5);
         % closed ring: first point equals last
         testCase.verifyEqual(xrect(1), xrect(end));
         testCase.verifyEqual(yrect(1), yrect(end));
         % spans the requested extent
         testCase.verifyEqual(min(xrect), 0);
         testCase.verifyEqual(max(xrect), 10);
         testCase.verifyEqual(min(yrect), 0);
         testCase.verifyEqual(max(yrect), 5);
      end
      function testMapboxReturnsPolyshape(testCase)
         % With no figures open and one output, mapbox returns a polyshape.
         close all force
         p = mapbox([0 10], [0 5]);
         testCase.verifyClass(p, 'polyshape');
      end

      % ---- geobox (regular-axis path -> mapbox) ----
      function testGeoboxRegularAxis(testCase)
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         ax = axes(fig); %#ok<NASGU>
         plot(0, 0); % make a regular cartesian axis current
         h = geobox([0 5], [0 10]);
         % geobox on a regular axis routes through mapbox; output should exist.
         testCase.verifyNotEmpty(h);
      end

      % ---- get_inset_coords (pure compute) ----
      function testGetInsetCoordsStruct(testCase)
         posMain = [0.1 0.1 0.8 0.8];
         posInset = [0.6 0.6 0.2 0.2];
         out = get_inset_coords([], posMain, posInset, ...
            [0 100], [0 50], [10 20], [5 15], 1:4);
         testCase.verifyClass(out, 'struct');
         for f = {'xUR', 'yUR', 'xLL', 'yLL', 'xLR', 'yLR', 'xUL', 'yUL'}
            testCase.verifyTrue(isfield(out, f{1}), ...
               sprintf('missing field %s', f{1}));
            testCase.verifyEqual(numel(out.(f{1})), 2);
            testCase.verifyTrue(all(isfinite(out.(f{1}))));
         end
      end

      % ---- parseMapProjection (returns projcrs / geocrs) ----
      function testParseMapProjectionProjcrsFromCode(testCase)
         mapProj = parseMapProjection(false, 3413, 'EPSG');
         testCase.verifyClass(mapProj, 'projcrs');
      end
      function testParseMapProjectionGeocrsFromCode(testCase)
         mapProj = parseMapProjection(true, 4326, 'EPSG');
         testCase.verifyClass(mapProj, 'geocrs');
      end
      function testParseMapProjectionPassthrough(testCase)
         p = projcrs(3413);
         out = parseMapProjection(false, p);
         testCase.verifyClass(out, 'projcrs');
         testCase.verifyEqual(out.ProjectionParameters, p.ProjectionParameters);
      end

      % ---- coverlay (overlay contours -> returns axes) ----
      function testCoverlayReturnsAxes(testCase)
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         [X, Y, Z] = testPlottingAndMisc.planarGridArrays();
         cm = contourc(X(1, :), Y(:, 1), Z, 5);
         imagesc(X(1, :), Y(:, 1), Z);
         ax = coverlay(cm);
         testCase.verifyTrue(isgraphics(ax, 'axes'));
         testCase.verifyNotEmpty(findobj(ax, 'Type', 'line'));
      end

      % ---- plotMapGrid (centroids + edges -> handle array) ----
      function testPlotMapGridReturnsHandles(testCase)
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         [X, Y] = testPlottingAndMisc.planarGridVectors();
         H = plotMapGrid(fig, X, Y);
         testCase.verifyTrue(isgraphics(H(1), 'figure'));
         testCase.verifyTrue(isgraphics(H(2), 'axes'));
         % axes should contain plotted objects (centroids / edges)
         testCase.verifyNotEmpty(get(H(2), 'Children'));
      end

      % ---- debugGridJumps (opens its own figure) ----
      function testDebugGridJumpsRuns(testCase)
         pre = findall(0, 'Type', 'figure');
         x = [0 10 20 30 50 60]; % a jump between 30 and 50
         [X, Y] = meshgrid(x, 0:10:40);
         debugGridJumps(X, Y); % creates a figure internally
         post = findall(0, 'Type', 'figure');
         newFigs = setdiff(post, pre);
         testCase.verifyNotEmpty(newFigs);
         close(newFigs);
      end

      % ---- contourLegend (legend on a contour plot) ----
      function testContourLegendReturnsLegend(testCase)
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         [X, Y, Z] = peaks(64);
         [~, hCont] = contour(X, Y, Z, 'LineWidth', 1.5);
         hLeg = contourLegend(hCont);
         testCase.verifyTrue(isgraphics(hLeg, 'legend'));
      end

      % ---- plotRbox (Mapping Toolbox) ----
      function testPlotRboxPlanar(testCase)
         testCase.assumeTrue(testPlottingAndMisc.mapToolbox(), ...
            'Mapping Toolbox not available.');
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         R = testPlottingAndMisc.planarR();
         [h, coords] = plotRbox(R);
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyEqual(numel(coords.x), 5);
         testCase.verifyEqual(numel(coords.y), 5);
      end

      % ---- patchRbox (Mapping Toolbox) ----
      function testPatchRboxPlanar(testCase)
         testCase.assumeTrue(testPlottingAndMisc.mapToolbox(), ...
            'Mapping Toolbox not available.');
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         R = testPlottingAndMisc.planarR();
         [h, coords] = patchRbox(R);
         testCase.verifyTrue(isgraphics(h, 'patch'));
         testCase.verifyEqual(numel(coords.x), 5);
         testCase.verifyEqual(numel(coords.y), 5);
      end

      % ---- plot_continents (worldmap, Mapping Toolbox) ----
      function testPlotContinentsRuns(testCase)
         testCase.assumeTrue(testPlottingAndMisc.mapToolbox(), ...
            'Mapping Toolbox not available.');
         pre = findall(0, 'Type', 'figure');
         h = plot_continents();
         cleanup = onCleanup(@() close(setdiff(findall(0, 'Type', 'figure'), pre)));
         testCase.verifyTrue(isstruct(h));
         testCase.verifyTrue(isgraphics(h.figure, 'figure'));
      end

      % ---- getlatlonticks (projinv + axes ticks) ----
      function testGetlatlonticksRuns(testCase)
         testCase.assumeTrue(testPlottingAndMisc.mapToolbox(), ...
            'Mapping Toolbox not available.');
         proj = projcrs(3413);
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         ax = axes(fig);
         % planar extent within the projection's valid range
         [x, y] = projfwd(proj, [70 72 74 76], [-50 -48 -46 -44]);
         plot(ax, x, y, 'o');
         [xt, yt, lonlab, latlab] = getlatlonticks(ax, proj);
         testCase.verifyTrue(isnumeric(xt));
         testCase.verifyTrue(isnumeric(yt));
         testCase.verifyClass(lonlab, 'cell');
         testCase.verifyClass(latlab, 'cell');
      end

      % ---- arcgridwrite2 (write ASCII grid to temp file) ----
      function testArcgridwrite2WritesFile(testCase)
         % Build a uniform meshgrid-oriented grid (equal dx == dy).
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         Z = magic(size(X, 1));
         Z = repmat(Z(:, 1), 1, size(X, 2));
         fname = [tempname '.asc'];
         cleanup = onCleanup(@() testPlottingAndMisc.tryDelete(fname));
         arcgridwrite2(fname, X, Y, Z);
         testCase.verifyTrue(isfile(fname));
         info = dir(fname);
         testCase.verifyGreaterThan(info.bytes, 0);
         % header should contain the standard Arc ASCII keywords
         txt = fileread(fname);
         testCase.verifyTrue(contains(txt, 'ncols'));
         testCase.verifyTrue(contains(txt, 'cellsize'));
      end

      % ---- copygeoprjtemplate (copy .prj template; needs env var) ----
      function testCopygeoprjtemplateCopies(testCase)
         % If the env var is unset, point it at the repo's templates folder so
         % the function under test can find geoprojtemplate.prj.
         src = fullfile(getenv('MATLAB_TEMPLATE_PATH'), 'geoprojtemplate.prj');
         if isempty(getenv('MATLAB_TEMPLATE_PATH')) || ~isfile(src)
            repoTemplates = fullfile( ...
               fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
               'templates');
            testCase.assumeTrue( ...
               isfile(fullfile(repoTemplates, 'geoprojtemplate.prj')), ...
               'geoprojtemplate.prj not found.');
            old = getenv('MATLAB_TEMPLATE_PATH');
            setenv('MATLAB_TEMPLATE_PATH', repoTemplates);
            restoreEnv = onCleanup(@() setenv('MATLAB_TEMPLATE_PATH', old));
         end
         dest = [tempname '.prj'];
         cleanup = onCleanup(@() testPlottingAndMisc.tryDelete(dest));
         copygeoprjtemplate(dest);
         testCase.verifyTrue(isfile(dest));
         info = dir(dest);
         testCase.verifyGreaterThan(info.bytes, 0);
      end

   end

   methods (Static)
      function tryDelete(fname)
         if isfile(fname)
            delete(fname);
         end
      end
   end
end
