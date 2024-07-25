function betterBarPlot(dataArray,showPairedDiffs)

   % %     see https://anneurai.net/2016/06/13/prettier-plots-in-matlab/
   % % and don't forget to mine through here github tools in mysource

   % example:
   %dataArray(:, 1) = randn(1, 50) + 10;
   %dataArray(:, 2) = randn(1, 50) + 12;

   %colors = cbrewer('qual', 'Set1', 10);
   colors = load('distinguishablecolors.mat').('dc');


   maxfig
   hold on
   % if we want each bar to have a different color, loop
   for b = 1:size(dataArray, 2)
      bar(b, mean(dataArray(:,b)), 'FaceColor',  colors(b, : ), ...
         'EdgeColor', 'none', 'BarWidth', 0.6);
   end

   % show standard deviation on top
   h = ploterr(1:2, mean(dataArray), [], std(dataArray), 'k.', 'abshhxy', 0);
   set(h(1), 'marker', 'none'); % remove marker

   % label what we're seeing
   % if labels are too long to fit, use the xticklabelrotation with about -30
   % to rotate them so they're readable
   set(gca, 'xtick', [1 2], 'xticklabel', {'low', 'high'}, ...
      'xlim', [0.5 2.5]);
   ylabel('Value'); xlabel('Data');

   % if these data are paired, show the differences
   if showPairedDiffs == true

      % mgc "dat" undefined, assumign it was dataArray and the transpose is
      % intended, could have been a typo.
      plot(dataArray', '.k-', 'linewidth', 0.2, 'markersize', 2);
      %plot(dat', '.k-', 'linewidth', 0.2, 'markersize', 2);
   end

   % significance star for the difference
   [~, pval] = ttest(dataArray(:, 1), dataArray(:, 2));
   % if mysigstar gets 2 xpos inputs, it will draw a line between them and the
   % sigstars on top
   mysigstar(gca, [1 2], 17, pval);

   % add significance stars for each bar
   for b = 1:2
      [~, pval] = ttest(dataArray(:, b));
      yval = mean(dataArray(:, b)) * 0.5; % plot this on top of the bar
      mysigstar(gca, b, yval, pval);
      % if mysigstar gets just 1 xpos input, it will only plot stars
   end

end
