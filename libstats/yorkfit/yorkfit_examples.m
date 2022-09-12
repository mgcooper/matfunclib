% see:
% https://cran.r-project.org/web/packages/lmodel2/vignettes/mod2user.pdf
% for a paper that has specific criteria on how to decide which linear
% regression method to use

% this one needs to be revisited:
% https://onlinelibrary.wiley.com/doi/full/10.1002/sam.11173

% see:
% https://www.frontiersin.org/articles/10.3389/feart.2021.613011/full
% they add measurement error, they have dn = d+e*d*r "where r is a vector
% of the same size as d composed of random samples drawn from a standard
% normal (Gaussian) distribution with a mean of 0 and a standard deviation
% of 1, and ϵ is the standard deviation of the noise, which is usually
% taken as 1/3 of the observation error. For this study, we set ϵ=0.0166
% for a 5% observation error.
% i.e. they add proportional, normally distributed error

% N   = 100;
% xmu = 5;
% a   = 2;
% b   = 3;
% x   = xmu.*sort(rand(N,1));
% y   = a+b.*x;
% r   = normrnd(0,1,N,1);
% e   = 0.05*mean(y);
% yobs= y+y.*e.*r;
% 
% figure; myscatter(x,y); hold on; myscatter(x,yobs);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% can bootstrap/monte carlo fix it?
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clean

% add measurement error with standard deviation 2, mean 0
data    = defaultCurveData;
x       = data.x;
y       = data.y;
xobs    = data.xobs;
yobs    = data.yobs;
xerr    = data.xerr;
yerr    = data.yerr;
rXY     = data.rxy;
xones   = ones(size(x));

% demonstrate attenuation bias with one set of data
abols   = round([ones(size(x)),xobs(:,1)]\yobs(:,1),2);

% plot the data
figure; myscatter(x,y,20); hold on; myscatter(xobs(:,1),yobs(:,1),20);
refline(abols(2),abols(1))
legend('true','noisy','ols fit','Location','nw')
title 'A linear relationship with noise and error'

% estimate the slope and intercept then average across all 
for i = 1:size(xobs,2)
    abolsi(:,i) = round([xones,xobs(:,i)]\yobs(:,i),2);
    abmlei(:,i) = yorkfit(xobs(:,i),yobs(:,i),xerr(:,i),yerr(:,i),0);
    abyrki(:,i) = yorkfit(xobs(:,i),yobs(:,i),xerr(:,i),yerr(:,i),rxy(i));
end
abolsmc   = round(mean(abolsi,2),2)
abmlemc   = round(mean(abmlei,2),2)
abyrkmc   = round(mean(abyrki,2),2)


% % generate correlated random errors
% mu      = 0;
% sig     = 0.50*mean(x);
% rxy     = -0.75;
% R       = [1 rxy; rxy 1];
% L       = chol(R);
% M       = (mu + sig*randn(N,2))*L;
% xerr    = M(:,1);
% yerr    = M(:,2);
% rxy     = corr(xerr,yerr); 
% 
% figure; myscatter(x,y); hold on; myscatter(x+xerr,y+yerr); 
% legend('y with noise','x-y with error')
% figure; scatterhist(xerr,yerr); title('correlated random error')

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% can the weights be computed and then fed into nlinfit or similar?
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
x       = xobs(:,1);
y       = yobs(:,1);
X       = [xones,x];
sigx    = xerr(:,1);
sigy    = yerr(:,1);
rxy     = rXY(:,1);
abtmp   = pcafit(x,y);
W       = yorkweights(sigx,sigy,rxy,abtmp(2));

abols   = round(X\y,2);
abmle   = yorkfit(x,y,sigx,sigy,0);
abyrk   = yorkfit(x,y,sigx,sigy,rxy);
    
% weighted is better than OLS, but doesn't get the right answer
abwls   = lscov(X,y,W);
W       = yorkweights(sigx,sigy,rxy,abwls(2));
abwls   = lscov(X,y,W);




