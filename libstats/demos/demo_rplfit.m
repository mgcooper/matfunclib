
%%

N = 10000;
xmin = 1;
lambda = 0.7;
alpha = lambda + 1;

x = plrand(10000, alpha, xmin);

% compute frequencies
% [M, edges] = histcounts(x);
[edges, centers] = logbinedges(x, 500);
M = histcounts(x, edges);
f = M./numel(M);

figure
loglog(centers, f)
set(gca, 'xlim', [min(x) 1e3])
% set(gca, 'xlim', [min(x) max(x)])

hold on

loglog(1:numel(f), sort(f))
set(gca, 'xlim', [min(x) 1e4])


Fx = (0:numel(f)-1)'./numel(f);
figure
loglog(f, 1-Fx)

%%
N = 10000;
xmin = 1;
lambda = 0.7;
% alpha = 1+1/lambda;
alpha = lambda + 1;
x = plrand(10000, alpha, xmin);
% x = plrand(10000, lambda, xmin);

figure
plplot(x, xmin, alpha)
plfit(x)

x = randht(N,'powerlaw',alpha);
figure
plplot(x, xmin, alpha)
plfit(x)
 
figure
plot(x)

[F, xx] = plcdf(x,xmin,lambda);

figure;
semilogy(xx, F)

figure; 
semilogy(1:N, sort(x))

%%

[M, edges] = histcounts(x);

figure; 
loglog(edges(1:end-1), M)

%%

figure
[h,edges,centers] = loghist(x);

counts = h.BinCounts;

figure
semilogy(centers, counts)

%%

Fx = (0:N-1)'./N; % the empirical cdf

figure
semilogy(1:N, 1-Fx)

figure
semilogy(sort(x), 1-Fx)

figure
semilogy(sort(x), Fx)



