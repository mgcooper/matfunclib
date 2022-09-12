%{

Before you perform linear regression, ask yourself two questions:

1) Am I performing linear regression to quantify a functional relationship
    between the variable on the x-axis and the variable on the y-axis? 
2) Are there measurement errors present in the data on the x-axis?

If the answer to these questions is yes, then ordinary least squares will
underestimate the slope and overestimate the intercept, and there is
nothing you can do to fix it, except to abandon ordinary least squares for
this type of problem. Increasing the sample size will not fix it. Normally
distributed errors with zero mean will not fix it. The presence of error on
the x-axis alone is the end of the road for OLS.   

The answer is to use a different class of regression referred to as
"errors-in-variables regression" or "measurement error regression". These
methods are similar, but not identical, to "total least squares", "Deming
regression", and principal components analysis in two-dimensions. In the
most common case, the method is identical to a Maximum Likelihood Estimate
of a linear regression with known error covariance, but not always. If the
relationship is non-linear, then things get complicated fast. 

This toolbox 

% functional: xi = fixed values
% structural: xi = random variable

%}




%{

I went through every textbook in my Zotero looking for insight into this
problem. While at it, I also wanted to find insight into power law fitting,
so below I keep track of what I found:

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Skiena, The Data Science Design Manual: 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EIV:
Pg. 267: an entire chapter on Linear Regression and no mention of EIV!

Power Law: 
Pg. 129 Power Law Distributions
Pg. 206 Linear vs NonLinear Models

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bonamente, Statistics and Analysis of scientific data
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EIV: 
Pg. 88: MLE estimate of the mean for non-uniform uncertainties
Pg. 91: MLE method of moments
Pg. 147: Chapter 6 MLE fit to a two-variable dataset (but when you go
there, on page 147 it says "the case of datasets with errors in both
variables is presented in Ch. 12"
Pg. 203: Chapter 12 Fitting Two-Variable Datasets with Bivariate Errors

Power Law: 

Note that this textbook has a good discussion of random / systematic error
that would have been helpful in my light attenuation study

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sheather: A Modern Approach to Regression In R
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Surprisingly, this does not seem to have anything on EIV

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hornberger and Wiberg, Numerical Methods in the Hydrological Sciences
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nothing on either


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
James, Introduction to Statistical Learning in R
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nothing

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Heiberger and Holland, Statistical Analysis and Data Display
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nothing - comprehensive but beginner, probably least useful of these so far

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bacciotti, Stability and Control of Linear Systems
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Since this is about system identification, it may have useful information,
but will be difficutl to decode due to terminology

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bramer, Principles of Data Mining
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
basincally all about classification


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trauth, Matlab Recipes for Earth Sciences
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EIV: pg 141 discusses 'reduced major axis regression' - points out that
slope of reduced major axis is Sy/Sx, or my 'sensitivity' parameter~

% contains a useful example of bootstrap and jacknife estimates of
regression coefficients that might be a better way to estimate the point
cloud, also cross-validation

% pg 145: nonlinar and weighted regression 


NOTE: in one of these textbooks, maybe the one right above this, I saw
someting called "SIMEX", and then it turns out this is discussed in
Carrol's measurement error textobok 

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Isermann, Identification of dynamical systems an introduction with applications
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

this might be very helpful, see Ch. 10

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BELOW ARE GENERAL NOTES AND IMPLEMENTATION

%{

TODO: consider implementing section 12.2 in Bonamente, at minimum consider
the error formulas, and whether the methods i use in yorkfit are correct

section 12.3 of Bonamente looks interesting, maybe totally differentv


NOTES:

FOR ALL IMPLEMENTATIONS BELOW, I NEED TO REMOVE THE RANDOM NOISE ON Y
AND/OR SEPARATE THIS OUT, B/C I'VE NOW CLARIFIED THAT YORK ONLY RECOVERS
THE TRUE SLOPE WHEN I START WITH PERFECT X/Y ... WHICH IMPLIES A
SENSITIVITY STUDY TO 'NATURAL VARIATION' I.E. BACKGROUND NOISE IN ADDITION
TO MEASUREMENT NOISE IS NEEDED. also, i could propagate the noise i add
onto the measurement noise and see what happens

measurement error models are required when the x variable is a
numerical approximation, as well as classic "measurement error" and
therefore would be required for Q vs dQ/dt via sgolay filter!

Mahon 1996 on standard error and goodness of fit:
goodness of fit and standard error estimates are mathematically independent
(Mahon 1996) meaning york could be used for ab estimates, but mle could be
used for standard error / conf. int. The York 1966 method uses the MSWD
parameter, the WIlliamson 1968 method is accurate but does not apply to
correlated errors. The York 1969 method has a typo for the intercept std.
error. the std. err is simply a function of the analytical errors
associated with each point, whereas gof is a measure of how well the data,
normalized by the analytical errors, fit a line. 
TLDR: nearly certian Mahon 1996 is superseded by York, 2004. The important
takeaway is (as noted above), std. error and parameter estimation can be
considered mathematically separate, and MOST IMPORTANTLY, using
t-distribution to get CI's after SE's are gotten is OK. The other important
thing is the monte carlo test at the end. i ran out of patience to work
thorugh it, but i think he just assumes different % error on x,y, and fits
york, the uses sigb = stdv(b)/sqrt(n)

can bootstrap/monte carlo be used without york? I.e., can I just create an
ensemble of predictors with the specified error? 

%}

%% this example works
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% note - if you set the sample size low, yorkfit will tend toward ols
% note - it looks like it is necessary to iterate yorkfit several times,
% but would need to resample the error distribution each time

% cehck noise2meas and other sytem identification toolbox functions

% 'factor analysis' might be appropriate - it is similar to PCA, here the
% 'factor' could be the PDO

% note - the MSWD errror metric at the end of York rleates to
% 'underdispersion' and 'overdispersion' and see the isochron package in R
% for "three ways" to deal with it

% clarify that yorkfit recovers the true fit when there is no noise, and
% how many samples are necessary to converge on it

% if you feed yorkfit the mean x/y error, you cannot feed it the
% correlation, even if it is known

% i think yorkfit recovers the true fit if the errors have mean zero and
% the standard deviation is given exactly

% NOTE: all of this assumes the error has mean zero, I think

clean

load('defaultcolors.mat');

% see https://www.mathworks.com/help/simbio/ug/error-models.html for
% matlab's built-in error model types

errtype = 3;    % 0=none, 1=constant, 2=constant,relative, 3=scaled
      N = 200;

x       = 10 .* sort(rand(N,1));
y       = 5 + 2*x + randn(N,1).*2;

figure;
scatter(x,y,'filled')
title 'A linear relationship with added noise'


switch errtype
    case 0                                      % constant scalar error
        xerr = zeros(size(x));
        yerr = zeros(size(y));
    case 1                                      % constant scalar error
        xerr = 0.10*mean(x).*randn(N,1);
        yerr = 0.10*mean(y).*randn(N,1);
%         yerr = randn(N,1);
        ttxt = 'Constant Error';
    case 2                                      % constant relative error
        xerr = 0.10.*x.*randn(N,1);
        yerr = 0.10.*y.*randn(N,1);
%         yerr = randn(N,1);
        ttxt = 'Constant Relative Error';
    case 3                                      % scaled relative error
        xerr = 0.02*mean(x)+0.10*x.*randn(N,1);
        yerr = 0.02*mean(y)+0.10*y.*randn(N,1);
%         yerr = randn(N,1);
        ttxt = 'Scaled Relative Error';
end

sigX    = std(xerr);  sigY = std(yerr);
xobs    = x+xerr; yobs = y+yerr;
rxy     = corr(xerr,yerr);
Xobs    = [ones(size(xobs)),xobs];
Xpca    = [xobs,xerr];  % I tried sigX*ones(size(x)) - PCA returns no loading

abtrue  = [ones(size(x)),x]\y;
abols   = [ones(size(xobs)),xobs]\yobs;
abyrk   = yorkfit(xobs,yobs,sigX,sigY,rxy);
abpca   = pcafit(xobs,yobs);
% abpls   = plsregress();

% [XL,YL,XS,YS,BETA,PCTVAR,MSE,stats] = plsregress([xobs xerr],yobs,1);
% [PCALoadings,PCAScores,PCAVar] = pca(Xpca,'Economy',false);
% betaPCR = regress(yobs-mean(yobs), PCAScores(:,1:2));
% betaPCR = PCALoadings(:,1:2)*betaPCR;
% betaPCR = [mean(y) - mean(Xpca)*betaPCR; betaPCR];
% yfitPCR = Xpca*betaPCR;

% with PCA, if you know the error variance, you might be able to construct
% an ensemble of error variables, and bootstrap regress. the reason i note
% this, is because if xerr is given to PCA, it will recover the true
% slope/intercpt, but just like with MLE, if you knew the error exactly,
% you would just subtract it, so I pass sigX and sigY as scalars to
% yorkfit, but you cannot pass a scalar to PCA, it returns zero loadings,
% so maybe if you did the above synthetic error test. 


figure('Position',[1 1 1152 624]); hold on;
h1 = scatter(x,y,'filled'); h2 = scatter(xobs,yobs,'filled');
h3 = refline(abtrue(2),abtrue(1)); h4 = refline(abyrk(2),abyrk(1));
h5 = refline(abols(2),abols(1)); h6 = refline(abpca(2),abpca(1));
h3.Color = c(1,:); h4.Color = c(2,:); h5.Color = c(3,:); h6.Color = c(4,:);
legend('true plus noise','observed plus error',                         ...
        ['true fit: y = ' printf(abtrue(2),2) 'x + ' printf(abtrue(1),2)], ...
        ['mle fit: y = ' printf(abyrk(2),2) 'x + ' printf(abyrk(1),2)], ...
        ['ols fit: y = ' printf(abols(2),2) 'x + ' printf(abols(1),2)], ...
        ['pca fit: y = ' printf(abpca(2),2) 'x + ' printf(abpca(1),2)], ...
        'Location','nw')
title(ttxt);
    
% note that pcafit to true data is identical to ols    


% h3 = plot(x,X*abtrue);
% h4 = plot(xobs,Xobs*abmle);
% h5 = plot(xobs,Xobs*abpca);

% SIMEX does



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% lessons leared
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% if you feed yorkfit the mean x/y error, you cannot feed it the
% correlation, even if it is known

% i had a typo and my 'true' x was generated with rand, not randn, and as a
% result, none of the solutions were converging ... note this means 'x' is
% a uniformly distributed variable, not random, which isn't something i was
% considering before this, it gets at the 'data generating process' and
% reminds me I need to consider generating Q with different distributions
% and see what happens

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% try bootstrapping
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clean

% add measurement error with standard deviation 2, mean 0
muerr   = 1;
sigerr  = 2;

Nboot   = 1000;
N       = 100;
x       = 10 .* sort(randn(N,1));
y       = 5 + 2*x;% + randn(N,1).*2;

% create an ensemble of random errors
xerr    = normrnd(muerr,sigerr,N,Nboot);
yerr    = normrnd(muerr,sigerr,N,Nboot);

% plot the data
% figure; myscatter(x,y,20); hold on; myscatter(x+xerr(:,1),y+yerr(:,1),20)
% title 'A linear relationship with noise and error'

% the mean of all columns of xerr and yerr have stdv 2, mean zero
mean(std(xerr,[],1));
mean(mean(xerr,1));

% but mean/std of any given column likely will not, unless N is large
std(xerr(:,randi(Nboot))); % run this over and over, 
mean(xerr(:,randi(Nboot)));

% for this reason, I cannot create a single vector of 'errors' with known
% mean and stdv equal in length to the data sample, unless the data sample
% is very large, and I also cannot use a single vector like this with
% bootstrp, because it just resamples the same vector over and over again,
% so on average


% choose a single vector of 'errors'
xobs    = x+xerr(:,1);
yobs    = y+yerr(:,1);
sigX    = mean(xerr(:,1));
sigY    = mean(yerr(:,1));
rxy     = corr(xerr(:,1),yerr(:,1));
rXY     = arrayfun(@(k) corr(xerr(:,k),yerr(:,k)), 1:Nboot, 'Uni', 1);

% plot the errors
% figure; myscatter(xerr(:,1),yerr(:,1)); hold on; myscatter(sigX,sigY,100);

% fit lines
xones   = ones(size(x));
abtrue  = round([xones,x]\y,2);
abols   = round([xones,xobs]\yobs,2);

% presume we know the average errors, but not the correlation, and
% choose not to use any advanced resampling or monte carlo techniques
abmle1  = round(yorkfit(xobs,yobs,sigX,sigY,0),2);

% presume we know the errors and therefore the correlation, and
% choose not to use any advanced resampling or monte carlo techniques
abmle2  = round(yorkfit(xobs,yobs,xerr(:,1),yerr(:,1),rxy),2);

% presume we know the errors and therefore the correlation, and
% choose to use monte carlo techniques
for i = 1:Nboot
    ab(:,i) = yorkfit(xobs,yobs,xerr(:,i),yerr(:,i),rXY(i));
end
abmle3     = round(mean(ab,2),2);

% presume we know the errors and therefore the correlation, and
% choose to use bootstrp 
abmle4      = round(mean(bootstrp(Nboot,@(xb,yb,rb) ...
              yorkfit(xobs,yobs,xb,yb,rb),xerr(:,1),yerr(:,1),rxy))',2);

% bootstrap outperforms because the actual errors are being resampled over
% and over, whereas monte carlo uses the entire distribution, which has a
% different mean/stdv than the single column

% to do a fair test, I need to run OLS for all combos ...
for i = 1:Nboot
    xobs        = x+xerr(:,i);
    yobs        = y+yerr(:,i);
    abolsi(:,i) = round([xones,xobs]\yobs,2);
    abmlei(:,i) = yorkfit(xobs,yobs,xerr(:,i),yerr(:,i),0);
    abyrki(:,i) = yorkfit(xobs,yobs,xerr(:,i),yerr(:,i),rXY(i));
end
abolsmc   = round(mean(abolsi,2),2)
abmlemc   = round(mean(abmlei,2),2)
abyrkmc   = round(mean(abyrki,2),2)

% mle/york give identical answers, despite the existence of correlation b/w
% the errors (albeit small)

% this shows that ols does not work if i simply perturb x with the known
% error distribution, but mle/york DOES

vars    = {'True','OLS','MLE1','MLE2','MLE3','MLE4','OLSmc','MLEmc'};
table(abtrue,abols,abmle1,abmle2,abmle3,abmle4,abolsmc,abmlemc,'VariableNames',vars)

%%        

% bootstrp resamples w/replacement all values, so

% xobs    = x+mean(xerr,2);
% yobs    = y+mean(yerr,2);
xobs    = x+xerr(:,1);
yobs    = y+yerr(:,1);
sigX    = mean(xerr(:,1));
sigY    = mean(yerr(:,1));
rXY     = arrayfun(@(k) corr(xerr(:,k),yerr(:,k)), 1:Nboot, 'Uni', 1);
rxy     = corr(xerr(:,1),yerr(:,1));

figure; scatter(x,y,'filled')
title 'A linear relationship with added noise'

abbootmle = mean(bootstrp(Nboot,@(xboot,yboot,cboot)                      ...
            yorkfit(xobs,yobs,xboot,yboot,cboot),xerr(:,1),yerr(:,1),rxy))'

% this is monte carlo        
for i = 1:Nboot
    ab(:,i) = yorkfit(xobs,yobs,xerr(:,i),yerr(:,i),rXY(i));
end
abmcmle     = mean(ab,2)

% pretend we don't know the errors, but we can guess the average error,
% does it make sense to generate a random sample equal in length to the
% number of observations N with mean equal to the guessed mean error, and
% then use that with bootstrp? Nope. the problem is that when I generate
% the random error sample of length N, the mean is very unlikely to be
% equal to the guessed mean:
sigXX   = randn(100,1)+sigX; mean(sigXX)
abbootmle  = mean(bootstrp(Nboot,@(xboot,yboot,cboot)                      ...
          yorkfit(xobs,yobs,xboot,yboot,cboot),xerr(:,1),sigYY,rxxyy))';
      
% instead what we want to do is generate Nboot random samples
sigXX   = randn(N,Nboot)+sigX;  mean(sigXX(:))

           

xones   = ones(size(x));
abtrue  = round([xones,x]\y,2);
abols   = round([xones,xobs]\yobs,2);
abpca   = round(pcafit(xobs,yobs),2);
abmle1  = round(yorkfit(xobs,yobs,sigX,sigY,0),2);
abmle2  = round(yorkfit(xobs,yobs,xerr(:,1),yerr(:,1),rxy),2);

vars    = {'True','OLS','MLE1','MLE2'};
table(abtrue,abols,abmle1,abmle2,'VariableNames',vars)


%%
sigX    = std(xerr).*randn(N,1) + mean(xerr);
sigY    = mean(yerr).*randn(N,1);
rxy     = corr(xerr,yerr);
abbootmle  = mean(bootstrp(Nboot,@(xboot,yboot,cboot)                      ...
                yorkfit(xobs,yobs,xboot,yboot,cboot),sigX,sigY,rxy))';
abglm   = bootgmregress(1000,xobs,yobs)';            
abpbk   = mean(bootstrp(Nboot,@(xboot,yboot)                            ...
                PassingBablok(x+xboot,y+yboot,false),sigX,sigY))';
abmar   = mean(bootstrp(Nboot,@(xboot,yboot)                            ...
                maregress(x+xboot,y+yboot),sigX,sigY))';
% abmar   = maregress(x,y);                   % major axis

figure; scatter(x,y); hold on; scatter(xobs,yobs);
h1 = refline(abtrue(2),abtrue(1)); h1.Color = c(1,:);
h2 = refline(abols(2),abols(1)); h2.Color = c(2,:);
h3 = refline(abyrk(2),abyrk(1)); h3.Color = c(3,:);
h4 = refline(abbootmle(2),abbootmle(1)); h4.Color = c(4,:); h4.LineStyle = ':';
legend([h1 h2 h3 h4],'true','ols','mle','mle boot','location','nw')


% can I bootstrap regular regression if I know the errors? 
abbootmle  = mean(bootstrp(Nboot,@(booterr)regress(yobs,[xones x+booterr]),xerr))';
geomean(bootstrp(Nboot,@(booterr)regress(yobs,[xones x+booterr]),xerr))'
% adding y-error doesn't help
% abboot  = mean(bootstrp(Nboot,@(bootxerr,bootyerr)regress               ...
%                 (yobs+bootyerr,[xones x+bootxerr]),xerr,yerr))';

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% trying to figure out why the mean/std of my samples arent as specified 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mu      = 0;
sig     = 2;

Nboot   = 1000;
N       = 1000;
xerr    = sig.*randn(N,Nboot) + mu;
yerr    = sig.*randn(N,Nboot) + mu;

% each column of xerr and yerr have stdv 2, mean zero, so the mean of all
% columns should also be 2 and 0:
mean(std(xerr,[],1))
mean(mean(xerr,1))


% ... normrnd is what i wanted 

xerr    = normrnd(mu,sig,N,Nboot);
yerr    = normrnd(mu,sig,N,Nboot);

mean(std(xerr,[],1))
mean(mean(xerr,1))

% for reference, if i wanted an exact mean/std
x=randn(100,1);
[mean(x),std(x)]    %random mean/std
x=x-mean(x);
[mean(x),std(x)]    %exact mean, random std
x=x/std(x);
[mean(x),std(x)]    %exact mean, exact std






%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% this example works
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% note - if you set the sample size low, yorkfit will tend toward ols
clean

load('defaultcolors.mat');

errtype    = 3;    % 1=constant, 2=constant,relative, 3=scaled

N       = 200;
Nfits   = 1000;

for i = 1:Nfits

    x = 10.*sort(rand(N,1));
    y = 2*x+5;
    
    switch errtype
        case 1                                      % constant scalar error
            xerr = 2.*randn(N,1);
            yerr = 2.*randn(N,1);
        case 2                                      % constant relative error
            xerr = 0.10.*x.*randn(N,1);
            yerr = 0.10.*y.*randn(N,1);
        case 3                                      % scaled relative error
            xerr = 0.02*mean(x)+0.05*x.*randn(N,1);
            yerr = 0.02*mean(y)+0.05*y.*randn(N,1);
    end

%     xerr    = (randn(size(x))+randn(size(x)))./2;
%     yerr    = (randn(size(y))+randn(size(y)))./2;
    
    sigX    = std(xerr);  sigY = std(yerr);
    xobs    = x+xerr; yobs = y+yerr;
    rxy     = corr(xerr,yerr);

    abtrue(:,i)  = [ones(size(x)),x]\y;
    abols(:,i)   = [ones(size(xobs)),xobs]\yobs;
    abyrk(:,i)   = yorkfit(xobs,yobs,sigX,sigY,rxy);
    abpca(:,i)   = pcafit(xobs,yobs);
    
    Xtrue(:,i)  = x;
    Ytrue(:,i)  = y;
    Xobs(:,i)   = xobs;
    Yobs(:,i)   = yobs;
    Xerr(:,i)   = xerr;
    Yerr(:,i)   = yerr;
    
end

% x       = mean(Xtrue,2);
% y       = mean(Ytrue,2);
% xobs    = mean(Xobs,2);
% yobs    = mean(Yobs,2);

x       = Xtrue(:);
y       = Ytrue(:);
xobs    = Xobs(:);
yobs    = Yobs(:);
sigX    = std(Xerr(:));
sigY    = std(Yerr(:));
rxy     = corr(Xerr(:),Yerr(:));

% abtrue  = [ones(size(x)),x]\y;
% abols   = [ones(size(xobs)),xobs]\yobs;
% abmle   = yorkfit(xobs,yobs,sigX,sigY,rxy);
% abpca   = pcafit(xobs,yobs);

mean(abtrue,2)
mean(abols,2)
mean(abyrk,2)
mean(abpca,2)

for i = 1:Nfits
    abmle_m(:,i) = mean(abyrk(:,1:i),2);
    abols_m(:,i) = mean(abols(:,1:i),2);
    abpca_m(:,i) = mean(abpca(:,1:i),2);
end

figure('Position',[1 1 1152 624]); hold on;
plot(1:Nfits,abols_m(1,:)); plot(1:Nfits,abmle_m(1,:));
plot(1:Nfits,abpca_m(1,:)); hline(abtrue(1));
xlabel('# of fits'); ylabel('intercept'); legend('OLS','MLE','PCA');

figure('Position',[1 1 1152 624]); hold on;
plot(1:Nfits,abols_m(2,:)); plot(1:Nfits,abmle_m(2,:));
plot(1:Nfits,abpca_m(2,:)); hline(abtrue(2));
xlabel('# of fits'); ylabel('slope'); legend('OLS','MLE','PCA');


% calculate with the entire sample size
abtrue  = [ones(size(Xtrue(:))),Xtrue(:)]\Ytrue(:);
abols   = [ones(size(Xobs(:))),Xobs(:)]\Yobs(:);
abyrk   = yorkfit(Xobs(:),Yobs(:),sigX,sigY,rxy);
abpca   = pcafit(Xobs(:),Yobs(:));

figure('Position',[1 1 1152 624]); hold on;
h1 = scatter(x,y,'filled'); h2 = scatter(xobs,yobs,'filled');
h3 = refline(abtrue(2),abtrue(1)); h4 = refline(abyrk(2),abyrk(1));
h5 = refline(abpca(2),abpca(1)); h6 = refline(abols(2),abols(1));
h3.Color = c(1,:); h4.Color = c(2,:); h5.Color = c(3,:); h6.Color = c(4,:);
legend('true','observed',                                               ...
        ['true fit: y = ' printf(abtrue(2),2) 'x + ' printf(abtrue(1),2)], ...
        ['mle fit: y = ' printf(abyrk(2),2) 'x + ' printf(abyrk(1),2)], ...
        ['pca fit: y = ' printf(abpca(2),2) 'x + ' printf(abpca(1),2)], ...
        ['ols fit: y = ' printf(abols(2),2) 'x + ' printf(abols(1),2)], ...
        'Location','nw')
% note that pcafit to true data is identical to ols    


% for reference - this would mean knowing every error exactly, in which
% case you would just subtract them!
% abmle   = yorkfit(xobs,yobs,xerr,yerr,rxy);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% experimenting with multiple regression 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
abmlr   = regress(yobs,Xobs)
abmlr   = regress(yobs,[Xobs xerr])
abmlr   = regress(yobs,[sigX.*ones(size(x)) xobs])
abmlr   = regress(yobs,[ones(size(x)) xobs sigX.*ones(size(x))])

% abmlr   = mvregress([sigY.*ones(size(y)) yobs],[sigX.*ones(size(x)) xobs])

% this shows how mlr can recover the exact value, but only if the errors
% are known exactly ... in which case we would just remove them!
% abmlr   = regress(y,X)
% abmlr   = regress(yobs,Xobs)
% abmlr   = regress(y,[Xobs xerr])
% abmlr   = regress(yobs,[Xobs xerr])


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% experimenting with lscov
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


covxy   = cov(x,y); covxy = covxy(2,1)*diag(ones(size(x)));
covobs  = cov(xobs,yobs); covobs = covobs(2,1)*diag(ones(size(x)));
coverr  = cov(xerr,yerr); coverr = abs(coverr(2,1)*diag(ones(size(x))));
xyerr   = sqrt(yerr.*yerr+xerr.*xerr);
wyerr   = 1./abs(yerr)./max(1./abs(yerr));
wxerr   = 1./abs(xerr)./max(1./abs(xerr));
wxyerr  = 1./abs(xyerr)./max(1./abs(xyerr));
xerrstd = std(xerr);
yerrstd = std(yerr);
xyerrstd = sqrt(xerrstd*xerrstd+yerrstd*yerrstd);
wxyerrstd = 1./xyerrstd.*ones(size(x));

ablscov = lscov(X,y,covxy);
ablscov = lscov(Xobs,yobs,covobs); % i thought if i put covxy here it would work
ablscov = lscov(Xobs,yobs,coverr);
ablscov = lscov(Xobs,yobs,wyerr);   % weighted, this one gets pretty close
ablscov = lscov(Xobs,yobs,wxerr);
ablscov = lscov(Xobs,yobs,wxyerr);
ablscov = lscov(Xobs,yobs,wxyerrstd);


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% repeat above with non-linear
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clean
load('defaultcolors.mat');

errtype = 1;    % 1=constant, 2=constant,relative, 3=scaled

a       = 0.003;
b       = 2;
c       = 0;    % for later- consider if c exists

N       = 200;
x       = 20+100*sort(rand(N,1));
y       = c+a.*x.^b; 

switch errtype
    case 1                                      % constant scalar error
        xerr = randn(N,1);
        yerr = randn(N,1);
        tstr = 'random scalar error';
    case 2                                      % constant relative error
        xerr = 0.05.*x.*randn(N,1);
        yerr = 0.05.*y.*randn(N,1);
        tstr = 'random proportional error';
    case 3                                      % scaled relative error
        xerr = 0.03*mean(x)+0.05*x.*randn(N,1);
        yerr = 0.03*mean(y)+0.05*y.*randn(N,1);
        tstr = 'proportional bias plus random proportional error';
end

figure; histogram(xerr); title('x error')
figure; histogram(yerr); title('y error')
figure; scatter(x,y); hold on; scatter(x+xerr,y+yerr);

xobs    = x+xerr;
yobs    = y+yerr;

% this is required when small flows get negative due to added noise
xobs    = abs(xobs);
yobs    = abs(yobs);
xerr    = abs(xerr);
yerr    = abs(yerr);

X       = [ones(size(x)),x];
Xobs    = [ones(size(xobs)),xobs];
sigX    = std(xerr);
sigY    = std(yerr);
rxy     = corr(xerr,yerr);

% fit the log-log regressions
abtrue      = [ones(size(x)),log(x)]\log(y);
abols       = [ones(size(xobs)),log(xobs)]\log(yobs);
abyrk       = (yorkfit(log(xobs),log(yobs),log(sigX),log(sigY),rxy))';
abmle       = mlefit(log(xobs),log(yobs),log(sigX),log(sigY));
abpca       = pcafit(log(xobs),log(yobs));
abtrue(1)   = exp(abtrue(1));
abols(1)    = exp(abols(1));
abyrk(1)    = exp(abyrk(1));
abmle(1)    = exp(abmle(1));
abpca(1)    = exp(abpca(1));

% fit with non-linear least squares
ft          = fittype(@(a,b,x) (a.*x.^b));
ftnls       = fit( xobs, yobs, ft, 'StartPoint',[0.01,0.01]);
abnls       = coeffvalues(ftnls);

% prep for plotting (not sure why I sorted, but works without)
% x       = sort(x);
% xobs    = sort(xobs);
ytrue   = abtrue(1).*x.^abtrue(2);
yols    = abols(1).*xobs.^abols(2);
yyrk    = abyrk(1).*xobs.^abyrk(2);
ymle    = abmle(1).*xobs.^abmle(2);
ypca    = abpca(1).*xobs.^abpca(2);
ynls    = abnls(1).*xobs.^abnls(2);

figure('Position',[1 1 1152 624]); tiledlayout(1,2); nexttile; hold on;
h1 = scatter(x,y,'filled'); h2 = scatter(xobs,yobs,'filled');
h3 = plot(x,ytrue); h4 = plot(xobs,yyrk); h5 = plot(xobs,ymle);         ...
h6 = plot(xobs,ypca); h7 = plot(xobs,yols); h8 = plot(xobs,ynls); 
set(gca,'XLim',[-5 max(xobs)],'YLim',[-5 max(yobs)]); 
hline(0,'k:');vline(0,'k:');
legend( [h1 h2 h3 h4 h5 h6 h7 h8],'true','observed',                    ...
   ['true fit: y = ' printf(abtrue(1),5) 'x^{' printf(abtrue(2),2) '}'],...
    ['yrk fit: y = ' printf(abyrk(1),5)  'x^{' printf(abyrk(2),2)  '}'],...
    ['mle fit: y = ' printf(abmle(1),5)  'x^{' printf(abmle(2),2)  '}'],...
    ['pca fit: y = ' printf(abpca(1),5)  'x^{' printf(abpca(2),2)  '}'],...
    ['ols fit: y = ' printf(abols(1),5)  'x^{' printf(abols(2),2)  '}'],...
    ['nls fit: y = ' printf(abnls(1),5)  'x^{' printf(abnls(2),2)  '}'],...
        'Location','nw')
title(tstr);

% log-scale
nexttile; hold on;
h1 = scatter(x,y,'filled'); h2 = scatter(xobs,yobs,'filled');
h3 = plot(x,ytrue); h4 = plot(xobs,yyrk); h5 = plot(xobs,ymle);         ...
h6 = plot(xobs,ypca); h7 = plot(xobs,yols); h8 = plot(xobs,ynls); 
set(gca,'XLim',[0 max(xobs)],'YLim',[0 max(yobs)],'YScale','log','XScale','log');
hline(0,'k:');vline(0,'k:');
legend( [h1 h2 h3 h4 h5 h6 h7 h8],'true','observed',                    ...
   ['true fit: y = ' printf(abtrue(1),5) 'x^{' printf(abtrue(2),2) '}'],...
    ['yrk fit: y = ' printf(abyrk(1),5)  'x^{' printf(abyrk(2),2)  '}'],...
    ['mle fit: y = ' printf(abmle(1),5)  'x^{' printf(abmle(2),2)  '}'],...
    ['pca fit: y = ' printf(abpca(1),5)  'x^{' printf(abpca(2),2)  '}'],...
    ['ols fit: y = ' printf(abols(1),5)  'x^{' printf(abols(2),2)  '}'],...
    ['nls fit: y = ' printf(abnls(1),5)  'x^{' printf(abnls(2),2)  '}'],...
        'Location','nw')
title(tstr);    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%



yfcn    = @(a,b,c,x)(a.*x.^b+c);
p0      = [0.01 0.01 0.01];
ab1     = nlinfit(x,y,yfcn,p0);
ab2     = nlinfit(x,yobs,yfcn,p0);
yfit1   = ab1(1)*exp(sort(x))+ab1(2);
yfit2   = ab2(1)*exp(sort(x))+ab2(2);

% plot the fits
figure; scatter(x,y); hold on; scatter(x,yobs);
plot(sort(x),yfit1); plot(sort(x),yfit2);

% weight by the noise and re-fit
yerr    = abs(randn(1,N));
werr    = sum(yerr)./yerr; % sum(1/werr)=1
yfcn    = @(phi,t)(werr.*(phi(1)*exp(t)+phi(2)));
ab3     = nlinfit(x,yobs,yfcn,p0,'Weights',werr);
yfit3   = ab3(1)*exp(sort(x))+ab3(2);


% plot the fits with the error
figure; scatter(x,y); hold on; scatter(x,yobs);
plot(sort(x),yfit1); plot(sort(x),yfit2);
errorbar(x,y,yerr,'o'); plot(sort(x),yfit3,'r');

% note - i need to double check whehter sorting is problmeatic i.e. the
% weights, and then compare true fit and effect of adding noise / wieghts


[t,q,tearly,qearly,tlate,qlate,h] = bfra_Qparlange;

figure; hold on;
scatter(tearly,qearly,'filled'); scatter(tlate,qlate,'filled')
set(gca,'YScale','log','XScale','log','YLim',[10 1e6])
legend('early','late')


% add noise to the early/late time
qearly  = qearly

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






abtrue  = X\y;
abols   = Xobs\yobs;
abyrk   = yorkfit(xobs,yobs,sigX,sigY,rxy);
% abmle   = yorkfit(xobs,yobs,xerr,yerr,rxy);
abfitlm = fitlm(xobs,yobs);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% THIS WAS THE ORIGINAL CODE, SHOULD WORK FINE, DOUBLE CHECK RAND/RANDN
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clean
load('defaultcolors.mat');

% note the way I have error setup its not +/- the error, its setup with
% average error = 0, +/- error up to max error, so it's more like noise
% I need to have error on each point that averages out to 10%

% case 1: constant random relative error
x       = (1:100)';
y       = 2*x+5;
xerr    = (10-20*rand(size(x)))./100;   % +/- 10% uniform error
yerr    = (2-4*rand(size(x)))./100;     % +/- 2% uniform error
xobs    = x+x.*xerr;
yobs    = y+y.*yerr;

X       = [ones(length(x),1) x];
Xobs    = [ones(length(x),1) xobs];
abtrue     = X\y;
abols     = [ones(size(xobs)) xobs]\yobs;
ab3     = yorkfit(xobs,yobs,std(xerr),std(yerr),corr(xerr,yerr));

% text for legend
ltext   =   ...
{   'true values'                                                        , ...
    'observed w/error'                                                   , ...
    ['OLS (true): y = ' printf(abtrue(1),2) ' + ' printf(abtrue(2),2) '*x'    ], ...
    ['OLS (w/error): y = ' printf(abols(1),2) ' + ' printf(abols(2),2) '*x' ], ...
    ['MLE (w/error): y = ' printf(ab3(1),2) ' + ' printf(ab3(2),2) '*x' ]};

f(1) = figure; hold on;
h(1) = scatter(x,y,12,c(1,:));                         % true values
h(2) = scatter(xobs,yobs,15,c(2,:));                   % values observed w/error
h(3) = plot(x,X*abtrue,'Color',c(1,:),'LineWidth',1);      % OLS on true values
h(4) = plot(x,X*abols,'Color',c(2,:),'LineWidth',1);   % OLS on observed values
h(5) = plot(x,X*ab3','Color',c(3,:),'LineWidth',1); % MLE on observed values
legend(h,ltext);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% loop through the error and compute slope/intercept error vs msrmt error
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clean
x       = (1:100)';
y       = 2*x+5;
xerrv   = 1:30;
yerrv   = 1:30;

% first analyze error in the y-variable, holding x-error constant at 10%
xerr    = (10-20*rand(size(x)))./100;   % +/- 10% uniform error
xobs    = x+x.*xerr;

% true fit, and baseline fit with X error +/- 10%
X       = [ones(length(x),1) x];
Xobs    = [ones(length(x),1) xobs];
abtrue     = X\y;
abols     = Xobs\y;
ab3     = yorkfit(xobs,y,std(xerr),0,0);

% loop through y-errors up to 
for i = 1:length(yerrv)

    yerri   = yerrv(i);
    yerr    = (yerri-2*yerri*rand(size(x)))./100;     % +/- uniform error
    
    yobs    = y+y.*yerr;    
    abols     = [ones(size(xobs)) xobs]\yobs;
    ab3     = yorkfit(xobs,yobs,std(xerr),std(yerr),corr(xerr,yerr));
end

    

% case 2: constant random absolute error

% case 3: variable random relative error

% case 4: variable random absolute error





%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% nlinfit from Matlab for Earth Sciences full example for reference
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% note - I made some small adjustments, could be adjusted back 

N       = 200;
x       = 3*sort(rand(N,1));
y       = 3+exp(x);
sigX    = 0.2;
sigY    = 0.5;
xerr    = sigX*randn(N,1);              % guassian noise w/ stdv=0.2
yerr    = sigY*randn(N,1);
xobs    = x+xerr;
yobs    = y+yerr;
X       = [ones(size(x)),x];
Xobs    = [ones(size(xobs)),xobs];
rxy     = corr(xerr,yerr);

scatter(x,y)


yfcn    = @(phi,t)(phi(1)*exp(t)+phi(2));
p0      = [0 0];
ab1     = nlinfit(x,y,yfcn,p0);
ab2     = nlinfit(x,yobs,yfcn,p0);
yfit1   = ab1(1)*exp(sort(x))+ab1(2);
yfit2   = ab2(1)*exp(sort(x))+ab2(2);

% plot the fits
figure; scatter(x,y); hold on; scatter(x,yobs);
plot(sort(x),yfit1); plot(sort(x),yfit2);

% weight by the noise and re-fit
yerr    = abs(randn(1,N));
werr    = sum(yerr)./yerr; % sum(1/werr)=1
yfcn    = @(phi,t)(werr.*(phi(1)*exp(t)+phi(2)));
ab3     = nlinfit(x,yobs,yfcn,p0,'Weights',werr);
yfit3   = ab3(1)*exp(sort(x))+ab3(2);


% plot the fits with the error
figure; scatter(x,y); hold on; scatter(x,yobs);
plot(sort(x),yfit1); plot(sort(x),yfit2);
errorbar(x,y,yerr,'o'); plot(sort(x),yfit3,'r');



%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% PCA full example for reference
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
rng(5,'twister');
X = mvnrnd([0 0 0], [1 .2 .7; .2 1 0; .7 0 1],50);
plot3(X(:,1),X(:,2),X(:,3),'bo');
grid on;
maxlim = max(abs(X(:)))*1.1;
axis([-maxlim maxlim -maxlim maxlim -maxlim maxlim]);
axis square
view(-9,12);

[coeff,score,roots] = pca(X);
basis   = coeff(:,1:2);
normal  = coeff(:,3);
[n,p]   = size(X);
meanX   = mean(X,1);
Xfit    = repmat(meanX,n,1) + score(:,1:2)*coeff(:,1:2)';
resids  = X - Xfit;
dirVect = coeff(:,1);
YXfit   = repmat(meanX,n,1) + score(:,1)*coeff(:,1)';
t       = [min(score(:,1))-.2, max(score(:,1))+.2];
endpts  = [meanX + t(1)*dirVect'; meanX + t(2)*dirVect'];

X      = [X(:,1) YXfit(:,1) nan*ones(n,1)];
Xobs      = [X(:,2) YXfit(:,2) nan*ones(n,1)];
X3      = [X(:,3) YXfit(:,3) nan*ones(n,1)];

figure;hold on
plot3(endpts(:,1),endpts(:,2),endpts(:,3),'k-');
plot3(X',Xobs',X3','b-', X(:,1),X(:,2),X(:,3),'bo');
hold off
maxlim = max(abs(X(:)))*1.1;
axis([-maxlim maxlim -maxlim maxlim -maxlim maxlim]);
axis square
view(-9,12);
grid on

lmfit   = fitlm([X(:,2) X(:,3)],X(:,1));

figure; plot(lmfit)

% commented out because it just verifies that it matches ols
% % pca with true
% X       = [y X1]; [coeff,score,roots] = pca(X);
% basis   = coeff(:,1:2);
% normal  = coeff(:,3);
% [n,p]   = size(X);
% meanX   = mean(X,1);
% Xfit    = repmat(meanX,n,1) + score(:,1:2)*coeff(:,1:2)';
% resids  = X - Xfit;
% dirVect = coeff(:,1);
% Xfit1   = repmat(meanX,n,1) + score(:,1)*coeff(:,1)';
% t       = [min(score(:,1))-.2, max(score(:,1))+.2];
% endpts  = [meanX + t(1)*dirVect'; meanX + t(2)*dirVect'];
% 
% xpcatrue    = endpts(:,2);
% ypcatrue    = endpts(:,1);
% abpcatrue   = [xpcatrue,ones(size(xpcatrue))]\ypcatrue;


% this was further up, not sure if redundant with ^^^
% for reference, this is how I got pca to work, before simplifying
% X       = [yobs X2]; [coeff,score,roots] = pca(X);
% basis   = coeff(:,1:2);
% normal  = coeff(:,3);
% [n,p]   = size(X);
% meanX   = mean(X,1);
% Xfit    = repmat(meanX,n,1) + score(:,1:2)*coeff(:,1:2)';
% resids  = X - Xfit;
% dirVect = coeff(:,1);
% Xfit1   = repmat(meanX,n,1) + score(:,1)*coeff(:,1)';
% t       = [min(score(:,1))-.2, max(score(:,1))+.2];
% endpts  = [meanX + t(1)*dirVect'; meanX + t(2)*dirVect'];
% xpca    = endpts(:,2);
% ypca    = endpts(:,1);
% abpca   = [xpca,ones(size(xpca))]\ypca;

