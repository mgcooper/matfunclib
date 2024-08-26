function tests = test_formatPlotMarkers
   tests = functiontests(localfunctions);
end

function testSingleLinePlot(testCase)
   % Test with a single line plot
   fig = figure;
   ax = axes;
   lineHandle = plot(ax, 1:10, rand(1, 10), '-o'); % Line plot with markers

   % Apply formatting
   formattedHandles = formatPlotMarkers("suppliedaxes", ax);

   expectedMarkerSize = 10;
   expectedLineWidth = 1;

   % Verify marker size and line width are set correctly
   testCase.verifyEqual(formattedHandles.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(formattedHandles.LineWidth, expectedLineWidth);

   close(fig);
end

function testMultipleLinesPlot(testCase)
   % Test with multiple lines in a single axes
   fig = figure;
   ax = axes;
   hold on
   line1 = plot(ax, 1:10, rand(1, 10), '-o'); % Line with markers
   line2 = plot(ax, 1:10, rand(1, 10), '-x'); % Line with markers
   line3 = plot(ax, 1:10, rand(1, 10), '-');  % Line without markers
   hold off

   % Apply formatting
   formattedHandles = formatPlotMarkers("suppliedaxes", ax);

   % Verify only lines with markers are formatted
   expectedMarkerSize = 10;
   expectedLineWidth = 1;

   % Verify two of the three lines are formatted
   expectedNumHandles = 2;
   testCase.verifyEqual(numel(formattedHandles), expectedNumHandles);

   testCase.verifyEqual(line1.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(line2.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(line3.MarkerSize, 6);  % Default MATLAB size
   testCase.verifyEqual(line1.LineWidth, expectedLineWidth);
   testCase.verifyEqual(line2.LineWidth, expectedLineWidth);
   testCase.verifyEqual(line3.LineWidth, get(groot, 'defaultLineLineWidth'));

   close(fig);
end

function testErrorBarPlot(testCase)
   % Test with an error bar plot
   fig = figure;
   ax = axes;
   x = 1:10;
   y = rand(1, 10);
   err = rand(1, 10) * 0.1;
   eb = errorbar(ax, x, y, err); % Error bar plot

   % Apply formatting
   formattedHandles = formatPlotMarkers("suppliedaxes", ax);

   % Verify that the error bars are formatted
   expectedMarkerSize = 10;
   expectedLineWidth = 0.5;
   expectedCapSize = 6;

   testCase.verifyEqual(eb.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(eb.LineWidth, expectedLineWidth);
   testCase.verifyEqual(eb.CapSize, expectedCapSize);

   % Now format the line width manually
   formatPlotMarkers("suppliedaxes", ax, 'LineWidth', 1);
   testCase.verifyEqual(eb.LineWidth, 1);

   close(fig);
end

function testBarPlotExclusion(testCase)
   % Test that bar plots are excluded from formatting
   fig = figure;
   ax = axes;
   barHandle = bar(ax, 1:10, rand(1, 10)); % Bar plot

   % Apply formatting
   formattedHandles = formatPlotMarkers("suppliedaxes", ax);

   % Verify bar plot was not affected
   testCase.verifyEmpty(formattedHandles)
   testCase.verifyEqual(barHandle.LineWidth, 0.5); % Default MATLAB width

   close(fig);
end

function testSubplot(testCase)
   % Test with subplots
   fig = figure;
   ax1 = subplot(2,1,1);
   ax2 = subplot(2,1,2);
   line1 = plot(ax1, 1:10, rand(1, 10), '-o');
   line2 = plot(ax2, 1:10, rand(1, 10), '-o');

   % Apply formatting
   formattedHandles = formatPlotMarkers("suppliedaxes", [ax1, ax2]);

   expectedMarkerSize = 10;
   expectedLineWidth = 1;

   % Verify formattedHandles is a cell array (one per axes)
   testCase.verifyEqual(numel(formattedHandles), 2)

   % Verify both subplots have formatted lines
   testCase.verifyEqual(line1.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(line2.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(line1.LineWidth, expectedLineWidth);
   testCase.verifyEqual(line2.LineWidth, expectedLineWidth);

   close(fig);
end

function testSpecificLine(testCase)
   % Test applying formatting to a specific line
   fig = figure;
   ax = axes;
   hold on
   line1 = plot(ax, 1:10, rand(1, 10), '-o');
   line2 = plot(ax, 1:10, rand(1, 10), '-x');

   % Apply formatting to only one line
   formattedHandle = formatPlotMarkers("suppliedaxes", ax, "suppliedline", line1);

   expectedMarkerSize = 10;
   expectedLineWidth = 1;

   % Verify only the specified line is formatted
   testCase.verifyEqual(formattedHandle.MarkerSize, expectedMarkerSize);
   testCase.verifyEqual(formattedHandle.LineWidth, expectedLineWidth);
   testCase.verifyEqual(line2.MarkerSize, 6); % Default MATLAB size
   testCase.verifyEqual(line2.LineWidth, get(groot, 'defaultLineLineWidth')); % Default MATLAB width

   close(fig);
end
