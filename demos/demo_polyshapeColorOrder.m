
ax = gca;
isFaceColorSet = false;
N = 8;
nextColor = nan(N, 3);
for n = 1:N
   [~, nextColor(n, :), ~] = matlab.graphics.chart.internal.nextstyle( ...
      ax, true, false);
end

% Load the default colors
c = defaultcolors;

% They're equal up to the first 7 because on 8 nextstyle resets to the first one
isequal(c(1:7, :), nextColor(1:7,:))

% This shows that polyshape does not have any special color order
P = polyshape(1,1);
for n = 1:8
   plot(P); hold on;
end
cP = get(gca,'ColorOrder');

isequal(c(1:7, :), cP(1:7,:))
