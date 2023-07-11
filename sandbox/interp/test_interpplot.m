function H = test_interpplot(X, Y, V, Xq, Yq, Vq, funclist)

% Plot original data and interpolated points
figure('Position', [187     1   712   536]);

for n = 1:numel(funclist)
   
   subtight(2, 2, n, 'style', 'fitted')
   scatter(X(:), Y(:), 300, V(:), 'filled'); hold on
   smartlabels(X(:), Y(:), V(:), 'C', 'Color', 'r', 'FontSize', 12);
   scatter(Xq, Yq, 600, Vq.(funclist(n)), 'o')
   title(funclist(n))
   if n > 2, xlabel('X'); end
   if isodd(n), ylabel('Y'); end
   axis square
   colorbar
   smartlabels(Xq, Yq, round(Vq.(funclist(n)), 2), 'C');
   
   H(n) = gca;
end

[H.XLim] = deal([min(X(:))-1 max(X(:))+1]);
[H.YLim] = deal([min(Y(:))-1 max(Y(:))+1]);
