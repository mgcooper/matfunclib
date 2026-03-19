% demo_binedges Compare several histogram binning rules.

rng default

clusteredData = [randn(250, 1); 4 + 0.4 * randn(120, 1)];
positiveData = exp(randn(400, 1));
methods = {'fd', 'stone', 'knuth', 'bayesian-blocks'};

figure
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact')

for n = 1:numel(methods)
   nexttile
   [edges, ~, ~, numbins] = binedges(clusteredData, 'BinMethod', methods{n});
   histogram(clusteredData, edges)
   title(sprintf('%s (%d bins)', methods{n}, numbins), 'Interpreter', 'none')
end

figure
[edges, ~, ~, numbins] = binedges(positiveData, 'BinMethod', 'stone', ...
   'Scale', 'log10');
histogram(positiveData, edges)
set(gca, 'XScale', 'log')
title(sprintf('stone log10 (%d bins)', numbins), 'Interpreter', 'none')
xlabel('Value')
ylabel('Count')
