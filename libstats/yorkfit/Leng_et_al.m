clean

% NOTE: I changed abols to have zero error

load('defaultcolors.mat');
% X = x + d;            % x = true x, d = random error (delta) N~(0,stdd^2)
% Y = y + e;            % y = true y, e = random error (epsilon) N~(0,stde^2)
% y = a + b*x;          % true relationship
% Y = a + b*(X-d) - e;  % observed relationship (error model)

% in words: d is the error on x that is not accounted for in OLS, it is
% characterized as mean zero and std dev. sigd

N       = 100;
x       = 10 .* sort(rand(N,1));
y       = 5 + 2*x + randn(N,1).*2;

% create an ensemble of random errors with mean zero
mu      = 0;
sig     = 2;
xerr    = normrnd(mu,sig,N,1);
yerr    = normrnd(mu,sig,N,1);
xobs    = x+xerr;
yobs    = y+yerr;

% figure; histogram(x); hold on; histogram(y); legend('true x','true y')
% figure; histogram(xerr); hold on; histogram(yerr); legend('x err','y err')
% figure; histogram(xobs); hold on; histogram(yobs); legend('x obs','y obs')

sigx    = std(xerr);
sigy    = std(yerr);
rxy     = corr(xerr,yerr);

abtru   = [ones(size(x)),x]\y;
abols1  = [ones(size(x)),x]\yobs;
abols2  = [ones(size(x)),xobs]\yobs;
abmle   = mlefit(xobs,yobs,sigx,sigy);          % = york if rxy=0
abpca   = pcafit(xobs,yobs);                    % = mle if sigx=sigy
abgmr   = gmrfit(xobs,yobs);                    % = mle if sigx^2=Sxx & sigy^2=Syy
abyrk   = yorkfit(xobs,yobs,sigx,sigy,rxy);


figure('Position',[1 1 1152 624]); hold on;
h1 = myscatter(x,y); 
h2 = myscatter(xobs,yobs);
h3 = refline(abtru(2),abtru(1));    h3.Color = c(1,:);
h4 = refline(abols1(2),abols1(1));  h4.Color = c(2,:); 
h5 = refline(abols2(2),abols2(1));  h5.Color = c(3,:); 
h6 = refline(abmle(2),abmle(1));    h6.Color = c(4,:); 
h7 = refline(abpca(2),abpca(1));    h7.Color = c(5,:); 
h8 = refline(abgmr(2),abgmr(1));    h8.Color = c(6,:); 
h9 = refline(abyrk(2),abyrk(1));    h9.Color = c(1,:); h9.LineStyle = ':';

set(gca,'XLim',[-5 max(xobs)],'YLim',[-5 max(yobs)]); 
hline(0,'k:');vline(0,'k:');
legend( [h1 h2 h3 h4 h5 h6 h7 h8 h9],'true','observed',                 ...
   ['true fit: y = ' printf(abtru(2),2) 'x + ' printf(abtru(1),2)],     ...
 ['y noise fit: y = ' printf(abols1(2),2)  'x + ' printf(abols1(1),2)],...
    ['ols fit: y = ' printf(abols2(2),2)  'x + ' printf(abols2(1),2)],  ...
    ['mle fit: y = ' printf(abmle(2),2)  'x + ' printf(abmle(1),2)],    ...
    ['pca fit: y = ' printf(abpca(2),2)  'x + ' printf(abpca(1),2)],    ...
    ['gmr fit: y = ' printf(abgmr(2),2)  'x + ' printf(abgmr(1),2)],    ...
    ['yrk fit: y = ' printf(abyrk(2),2)  'x + ' printf(abyrk(1),2)],    ...
        'Location','nw')
% title(tstr);

% % log-scale
% nexttile; hold on;
% h1 = scatter(x,y,'filled'); h2 = scatter(xobs,yobs,'filled');
% h3 = plot(x,ytrue); h4 = plot(xobs,yyrk); h5 = plot(xobs,ymle);         ...
% h6 = plot(xobs,ypca); h7 = plot(xobs,yols); h8 = plot(xobs,ynls); 
% set(gca,'XLim',[0 max(xobs)],'YLim',[0 max(yobs)],'YScale','log','XScale','log');
% hline(0,'k:');vline(0,'k:');
% legend( [h1 h2 h3 h4 h5 h6 h7 h8],'true','observed',                    ...
%    ['true fit: y = ' printf(abtru(1),5) 'x^{' printf(abtru(2),2) '}'],...
%     ['yrk fit: y = ' printf(abyrk(1),5)  'x^{' printf(abyrk(2),2)  '}'],...
%     ['mle fit: y = ' printf(abmle(1),5)  'x^{' printf(abmle(2),2)  '}'],...
%     ['pca fit: y = ' printf(abpca(1),5)  'x^{' printf(abpca(2),2)  '}'],...
%     ['ols fit: y = ' printf(abols(1),5)  'x^{' printf(abols(2),2)  '}'],...
%     ['nls fit: y = ' printf(abnls(1),5)  'x^{' printf(abnls(2),2)  '}'],...
%         'Location','nw')
% title(tstr);    

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% determine situations where yorkfit recovers the true fit
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clean

N       = 100;
x       = 10 .* sort(rand(N,1));
y       = 5 + 2*x + randn(N,1).*2;

% create an ensemble of random errors
mu      = 2;
sig     = 3;
xerr    = normrnd(mu,sig,N,1);
yerr    = normrnd(mu,sig,N,1);
xobs    = x+xerr;
yobs    = y+yerr;

figure; hold on;
myscatter(x,y); myscatter(xobs,yobs);

sigx        = xerr;
sigy        = yerr;
sigxstd     = std(xerr);
sigystd     = std(yerr);
sigxavg     = xerr;
sigyavg     = yerr;
rxy         = corr(sigx,sigy);
rxystd      = corr(sigxstd,sigystd);
rxyavg      = corr(sigxavg,sigyavg);

% abmletru    = mlefit(xobs,yobs,0,0)
% abmlesig    = mlefit(xobs,yobs,sigx,sigy)
abols1       = [ones(size(x)),x]\yobs;
abmlestd    = mlefit(xobs,yobs,sigxstd,sigystd)
abmleavg    = mlefit(xobs,yobs,sigx,sigy)


%%
abtru   = [ones(size(x)),x]\y;
abols1   = [ones(size(x)),xobs]\yobs;
abmle   = mlefit(xobs,yobs,sigx,sigy);          % = york if rxy=0
abpca   = pcafit(xobs,yobs);                    % = mle if sigx=sigy
abgmr   = gmrfit(xobs,yobs);                    % = mle if sigx^2=Sxx & sigy^2=Syy
abyrk   = yorkfit(xobs,yobs,sigx,sigy,rxy);









































