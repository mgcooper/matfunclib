% mgc many errors existed due to newline formatting, basically lines were
% continued as newlines and I had to just delete the newline, but in case
% the script doesn't work, consider redownloading

% This code is provided as an electronic supplement to the G-cubed
% article on non-linear curve fitting, "Application of Maximum Likelihood
% and Bootstrap methods to non-linear curve-fit problems in geochemistry"
% by R. A. Sohn and W. Menke.
%
% This is a Matlab script to perform maximum likelihood inversion of a straight
% line to x- and y- data, when x- and y- are considered random variables
% with known errors. Data is expected as 4 columns; (1) x, (2) y, (3) std-x,
% (4) std-y. When non-zero values are provided for both columns 3 and 4 the
% script uses the non-linear, Exponential based Max. Likelihood
% method described
% in the G-cubed article to find a solution.
%
% Bootstrapping is used to estimate standard errors and generate confidence
% limits of parameter estimates.
%
% This code is intended for research purposes only, and was originally
% developed for isochron fitting. Please direct any questions about
% the code to Rob Sohn via email: rsohn@whoi.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%      NOTE: This script calls 2 functions; linLS and rxy
%            These are also Matlab .m files that must be loaded
%            into the same directory as this script so they
%            can be accessed by the code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Script to fit a straight line to double error data using a specified
% norm, e.g., L1, L2, etc. Based on maximum likelihood principles
% and using the method of steepest descent to find a final solution.
% Initial guess for slope and intercept and their associated variance
% can be manually input, or determined via a linear least squares
% estimate. Data are read as a 4-column file, with the columns being,
% (1) x, (2) y, (3) sigma-x, (4) sigma-y, respectively.
%
% RAS 8/01
%
% Bootstrapping is used to estimate standard errors and generate confidence
% limits of parameter estimates.
% RAS 2/00
%
% m1 for intercept, m2 for slope.
%

% read in x,y data pairs
%

fprintf('Data file must have 4 columns; x, y, std-x, std-y\n');
inpS=input('Data file name ?','s');
f1=fopen(inpS,'r');
data=fscanf(f1,'%f %f %f %f',[4 Inf]);
data=data';
[N,col]=size(data);
fclose(f1);

em=zeros(2,1);
em(1)=mean(data(:,3));
em(2)=mean(data(:,4));
epc=min(em)/(1000);

% if dataset is not double error, set errors to unity in appropos column(s)

if data(:,3)==zeros(N,1)
    data(:,3)=ones(N,1);
    xj=1;
    yj=2;
elseif data(:,3)~=zeros(N,1) && data(:,4)==zeros(N,1)
    data(:,4)=ones(N,1);
    xj=2;
    yj=1;
else
    xj=1;
    yj=2;
end

figure(1)
clf
plot(data(:,1),data(:,2),'o');

hold on


% needed to plot errors below

xvar=zeros(2*N,1);
xvar(1:N)=data(:,3).^2; % z (or x-axis) variance
xvar(N+1:2*N)=data(:,4).^2;        % y variance


% plot error bars

for j=1:N
    ex=[data(j,1)-sqrt(xvar(j)), data(j,1)+sqrt(xvar(j))];
    ey=[data(j,2)-sqrt(xvar(N+j)), data(j,2)+sqrt(xvar(N+j))];
    plot(ex,[data(j,2), data(j,2)])
    plot([data(j,1), data(j,1)],ey)
end

% get prior information for regression

m2pc=input('\nInitial values for slope, <cr> for automatic : ');
m1pc=input('\nInitial values for intercept, <cr> for automatic : ');
fprintf('\n\nSlope constraints:\n\n<cr>=unconstrained\n<0>=hard constraint\n ');
m2cc=input('or input user defined standard deviation : ');
fprintf('\n\nIntercept constraints:\n\n<cr>=unconstrained\n<0>=hard constraint\n ');
m1cc=input('or input user defined standard deviation : ');


if (isempty(m2pc) || isempty(m1pc))

% do an initial linear least squares fit to get uncertainty
% estimates for slope and intercept

    [m0,mv0,yh0]=linLS(data,xj,yj);
    M1=m0(1);
    M2=m0(2);
end

if ~isempty(m2pc)
    M2=m2pc;
end
if ~isempty(m1pc)
    M1=m1pc;
end

if isempty(m2cc)
    SM2=1e30;
elseif m2cc==0
    SM2=1e-30;
else
    SM2=m2cc;
end

if isempty(m1cc)
    SM1=1e30;
elseif m1cc==1
    SM1=1e-30;
else
    SM1=input('Input intercept standard deviation ');
end


% normalize data to unit amplitude and zero mean to make
% convergence of steepest descent method easier

xbar=mean(data(:,1));
ybar=mean(data(:,2));
x0=data(:,1)-xbar;
y0=data(:,2)-ybar;
a=max(abs(x0));
b=max(abs(y0));
xo=x0/a;	% new variables to use in inversion
yo=y0/b;	% normalized to zero mean and unit variance
sx=data(:,3)/a;
sy=data(:,4)/b;
m1a=(M1+M2*xbar-ybar)/b;
m2a=a*M2/b;
nmdata=zeros(N,4);
nmdata(:,1)=xo;
nmdata(:,2)=yo;
nmdata(:,3)=sx;
nmdata(:,4)=sy;

em=zeros(2,1);
em(1)=mean(nmdata(:,3));
em(2)=mean(nmdata(:,4));
epc=min(em)/(1000);

fprintf('Automatically selected convergence parameter is %e\n\n',epc);
chc=input('Enter desired convergence parameter or <return> to accept above value');
if isempty(chc) ~= 1
    if chc < 0
      error('Convergence parameter must be positive');
    end
    epc=chc;
end

% get bootstrapping (error estimation) info

B=input('How many bootstrap samples for standard error estimate ?\n');

if isempty(B) || B < 0 || B > 6000
    error('Must enter a positive integer number < 6000');
elseif B==0
    bsf=1;
else
    bsf=B+1;
end

%
% initialize arrays and begin bootstrapping
%

M1b=zeros(bsf,1);	% storing estimates, first entry is estimate
from true data
M2b=zeros(bsf,1);
r=zeros(bsf,1);
rw=zeros(bsf,1);
clear corr corrw

bs=0;	% bootstrap counter = how many times have we calculated slope and intercept

fprintf('Working on Bootstrap sample #     ');

% ********************
%
% begin main bootstrapping loop for calculating model parameters
%
% ********************

while bs < bsf	% while we haven't done all bootstrap calculations...

    fprintf('\b\b\b\b%4d',bs);	% print of bootstrap sample number

% form bootstrap sample, or use original if first pass

    bdata=zeros(size(data));
    if bs==0
      bdata=nmdata;
      m1=m1a;
      m2=m2a;
    else
      sameflag=1;
      while sameflag==1
        bi=ceil(rand(N,1)*N);
        bdata=nmdata((bi),:);
        sameflag=0;
        if bi-bi(1)==zeros(N,1)  % if bootstrap sample is one point repeated...
          sameflag=1;
        end
      end     % endwhile

% get new priors for each bootstrap replicate

      [m0,mv0,yh0]=linLS(bdata,xj,yj);
      m1=m0(1);
      m2=m0(2);

    end

% do ordinary or weighted least squares to get first guess of model
% parameters and variance


    [mest,mvar,Xhat]=linLS(bdata,xj,yj);

    if bs==0
      xdel=zeros(N,1);
      rstud=zeros(N,1);
      hatdiag=zeros(N,1);
      [rtemp,mz,SZZ]=rxy(bdata,xj,yj);    % unweighted estimate
      xdel=bdata(:,yj)-Xhat;	% residuals
      sighat=sqrt((sum(xdel))/(N-2)); % unbiased posterior variance estimate
      hatdiag=((bdata(:,xj)-mz).^2)/SZZ+1/N;
      rstud=xdel./(sighat*sqrt(ones(N,1)-hatdiag)); % stud. res
      rstud=rstud.*sqrt((ones(N,1)*(N-3))./(ones(N,1)*N-2-rstud.^2)); % ext. stud. res.
    end


% calculate correlation coefficient, both with and without weighting


    rdata=bdata;
    [rw(bs+1),mzw,SZZw]=rxy(rdata,xj,yj);	% call rxy function for weighted estimate
    rdata(:,3:4)=ones(N,2);
    [r(bs+1),mz,SZZ]=rxy(rdata,xj,yj);	% unweighted estimate
% save if first time through
    if bs==0
      corr=r(bs+1);
      corrw=rw(bs+1);
    end

    [rj,mx,SXX]=rxy(data,xj,yj);	% call to get values for studentizing later

% get a priori paramters and model variance

    clear xp
    xp=bdata(:,1);
    xi=bdata(:,1);	% observed x and y values
    yi=bdata(:,2);
    sxi=bdata(:,3);
    syi=bdata(:,4);	% std. dev, or error of x and y values
    m1p=m1;
    m2p=m2;	% for first pass priors are set to obvserved and initial

    [Fv]=L1(xi,yi,sxi,syi,M1,M2,SM1,SM2,m1p,m2p,xp,a,b,xbar,ybar);
	% calculate objective func.
    F=sum(Fv);
    if bs==0
      Forig=F;	% set initial value of objective function
    end
    accept=1;	% set gradient flag
    D=0.1;	% set convergence parameter

% enter loop for gradient method

    while (D>epc)	% while convergence condition isn't satisfied

      if (accept==1)

 
[delF]=L1grad(m1p,m2p,xp,M1,M2,SM1,SM2,xi,yi,sxi,syi,a,b,xbar,ybar);
	% gradient routine
        m1grad=sum(delF(:,N+1));
        m2grad=sum(delF(:,N+2));
        xpgrad=diag(delF(1:N,1:N));

        mg=[m1grad;m2grad;xpgrad];	% normalize
        maxg=max(abs(mg));
        m1grad=m1grad/maxg;
        m2grad=m2grad/maxg;
        xpgrad=xpgrad/maxg;

      end

% apply damped gradients to form new predictions

      m1p2=m1p-D*m1grad;
      m2p2=m2p-D*m2grad;
      xp2=xp-D*xpgrad;

% recalculate objective function

      [Fv2]=L1(xi,yi,sxi,syi,M1,M2,SM1,SM2,m1p2,m2p2,xp2,a,b,xbar,ybar);
      F2=sum(Fv2);



% check against previous value and act accordingly

      if (F2 < F)

        m1p=m1p2; % improvement, increment predictions
        m2p=m2p2;
        xp=xp2;
        F=F2;
        D=D*1.01;
        accept=1;
      else
        accept=0;	% don't recalculate gradient,
        D=D*0.99;	% just reduce magnitude

      end

    end	% end while convergence

    if bs==0
      Ffinal=F;
    end

    M1b(bs+1)=m1p*b-(b*m2p*xbar/a)+ybar; % save values into storage vectors
    M2b(bs+1)=m2p*b/a;


% **************************
%
% calculate Mean Absolute Value of Weighted Deviates (MAWD), and
studentized residuals
% if first time through
%
% **************************

    if bs==0
      clear xdel mawd dxy sighat rstud hatdiag Xhat0 Yhat0 yvar
      Xhat0=xp*a+xbar; % save for later comparison with jacknife values
      Yhat0=(xp*m2p+m1p)*b+ybar;
      xdel=zeros(2*N,1); % adjustment of each data point divided by prior variance
      dxy=zeros(N,1); % weighted Euclidean distance of data adjustment
      rstud=zeros(N,1); % studentized (externally) residual
      hatdiag=zeros(N,1); % diagonal of hat matrix
      xdel(1:N)=abs(data(:,1)-Xhat0);
      xdel(N+1:2*N)=abs(data(:,2)-Yhat0);
      yvar=(data(:,2)-Yhat0).^2;
      sighat=sqrt(sum(yvar)/(N-2)); % unbiased posterior variance estimate
      hatdiag=((data(:,1)-mx).^2)/SXX+1/N;
      rstud=(data(:,2)-Yhat0)./(sighat*sqrt(ones(N,1)-hatdiag)); % stud. res.
      rstud=rstud.*sqrt((ones(N,1)*(N-3))./(ones(N,1)*N-2-rstud.^2)); % ext. stud. res.
      xdel=xdel./sqrt(xvar(1:2*N));	% weighted by inverse variance
      dxy=xdel(1:N)+xdel(N+1:2*N);	% square of total variation
      mawd=mean(dxy);	% mean square of weighted deviates
    end

    bs=bs+1;	% increment bootstrap counter

end	% end while bootstrap flag


% **********************
%
% find bootstrap estimate of standard error for slope and intercept
%
% **********************

clear M1bmn M2bmn seM1 seM2

M1bmn=sum(M1b)/bsf;
M2bmn=sum(M2b)/bsf;
seM1=sqrt(sum((M1b-M1bmn).^2)/(bsf-1)); % std. error of m1
seM2=sqrt(sum((M2b-M2bmn).^2)/(bsf-1)); % std. error of m2


% ***********************
%
% use studentized residuals for outlier test
% critical values for outliers are based on the Bonferroni inequality
% see Weisberg (1985) p. 116
%
% degrees of freedom = N - 3
% Bonferroni significance level = acv/N*100%, acv= .05 (95% confidence)
%
% ****************************


acv=.05;
cv=tinv(1-acv/N,N-3);	% critical value for outlier detection
outind=find(rstud >= cv | rstud <= -cv);


% ***********************
%
% confidence limit and influence of cases calculations
% Confidence limits estimated using the BCa, or Bias Corrected
% and accelerated method
%
% do jackknife to get acceleration parameter which corrects
% confidence limits for the rate of change of the standard error
% of the estimated parameters with respect to the true parameter values
%
% Efron and Tibshirani, 1993, p. 186
%
% ***********************

jdata=zeros(N-1,4);
M1j=zeros(N,1);
M2j=zeros(N,1);
rj=zeros(N,1);
rjw=zeros(N,1);
IM1=zeros(N,1);	% influence of cases
IM2=zeros(N,1); % influence of cases

fprintf('\nJackknifing to correct confidence limits for error acceleration\n');
fprintf('Working jackknife sample #     ');
for j=1:N
    fprintf('\b\b\b\b%4d',j);
    jcount=1;
    for k=1:N	% form jth jackknife sample
      if k~=j
        jdata(jcount,:)=nmdata(k,:);
        jcount=jcount+1;
      end
    end

% calculate jackknife correlation coefficients

    rwj(j)=rxy(jdata,xj,yj);	% weighted rxy calc
    j1data=zeros(N-1,4);
    j1data(:,1:2)=jdata(:,1:2);
    j1data(:,3:4)=ones(N-1,2);
    rj(j)=rxy(j1data,xj,yj);	% unweighted

% calculate jackknife slope and intercept
% first do linear least squares to get prior parameter estimates

    xp=zeros(N-1,1);
    xp=jdata(:,1);
    xi=jdata(:,1);        % observed x and y values
    yi=jdata(:,2);
    sxi=jdata(:,3);
    syi=jdata(:,4);       % std. dev, or error of x and y values

% get new priors for each jackknife replicate

    [m0,mv0,yh0]=linLS(jdata,xj,yj);
    m1=m0(1);
    m2=m0(2);
    m1p=m0(1);
    m2p=m0(2);


    [Fv]=L1(xi,yi,sxi,syi,M1,M2,SM1,SM2,m1p,m2p,xp,a,b,xbar,ybar);   % calculate objective func.
    F=sum(Fv);
    accept=1;     % set gradient flag
    D=0.1;        % set convergence parameter

% enter loop for gradient method

    while (D>epc) % while convergence condition isn't satisfied

      if (accept==1)

        [delF]=L1grad(m1p,m2p,xp,M1,M2,SM1,SM2,xi,yi,sxi,syi,a,b,xbar,ybar);

        m1grad=sum(delF(:,N));
        m2grad=sum(delF(:,N+1));
        xpgrad=diag(delF(1:N-1,1:N-1));

        mg=[m1grad;m2grad;xpgrad];
        maxg=max(abs(mg));
        m1grad=m1grad/maxg;
        m2grad=m2grad/maxg;
        xpgrad=xpgrad/maxg;

      end

% apply damped & normalized gradients to form new predictions

      m1p2=m1p-D*m1grad;
      m2p2=m2p-D*m2grad;
      xp2=xp-D*xpgrad;

% recalculate objective function

      [Fv2]=L1(xi,yi,sxi,syi,M1,M2,SM1,SM2,m1p2,m2p2,xp2,a,b,xbar,ybar);
      F2=sum(Fv2);

% check against previous value and act accordingly

      if (F2 < F)

        m1p=m1p2; % improvement, increment predictions
        m2p=m2p2;
        xp=xp2;
        F=F2;
        D=D*1.01;
        accept=1;
      else
        accept=0; % don't recalculate gradient,
        D=D*0.99; % just reduce magnitude

      end

    end   % end while convergence

    M1j(j)=m1p*b-(b*m2p*xbar/a)+ybar; % save values into storage vectors
    M2j(j)=m2p*b/a;

%
% calculate influence of cases, similar to Cook's distance
%

IM1(j)=((M1j(j)-M1b(1))^2)/seM1^2;
IM2(j)=((M2j(j)-M2b(1))^2)/seM2^2;

end   % end for j loop forming jacknife samples

% calculate the acceleration...

M1m=mean(M1j);	% mean jackknife values
M2m=mean(M2j);
rm=mean(rj);
rwm=mean(rwj);
clear atop abot aM1 aM2 ar arw
atop=sum((M1m-M1j).^3);
abot=6*(sum((M1m-M1j).^2)^(3/2));
aM1=atop/abot;	% acceleration for m1
clear atop abot
atop=sum((M2m-M2j).^3);
abot=6*(sum((M2m-M2j).^2)^(3/2));
aM2=atop/abot;	% acceleration for m2
clear atop abot
atop=sum((rm-rj).^3);
abot=6*(sum((rm-rj).^2)^(3/2));
ar=atop/abot;	% acceleration for r
clear atop abot
atop=sum((rwm-rwj).^3);
abot=6*(sum((rwm-rwj).^2)^(3/2));
arw=atop/abot;	% acceleration for rw

% now compute the bias correction...

% standard will be to use 95% confidence limits

p=0.025;	% confidence limit to calculate

clear z0M1 z0M2 z0r z0rw
z0M1=norminv((length(find(M1b < M1b(1)))/B),0,1);
z0M2=norminv((length(find(M2b < M2b(1)))/B),0,1);
z0r=norminv((length(find(r < r(1)))/B),0,1);
z0rw=norminv((length(find(rw < rw(1)))/B),0,1);
clear a1M1 a2M1 a1M2 a2M2 a1r a2r a1rw a2rw
a1M1=normcdf(z0M1+(z0M1+norminv(p,0,1))/(1-aM1*(z0M1+norminv(p,0,1))));
a2M1=normcdf(z0M1+(z0M1+norminv(1-p,0,1))/(1-aM1*(z0M1+norminv(1-p,0,1))));
a1M2=normcdf(z0M2+(z0M2+norminv(p,0,1))/(1-aM2*(z0M2+norminv(p,0,1))));
a2M2=normcdf(z0M2+(z0M2+norminv(1-p,0,1))/(1-aM2*(z0M2+norminv(1-p,0,1))));
a1r=normcdf(z0r+(z0r+norminv(p,0,1))/(1-ar*(z0r+norminv(p,0,1))));
a2r=normcdf(z0r+(z0r+norminv(1-p,0,1))/(1-ar*(z0r+norminv(1-p,0,1))));
a1rw=normcdf(z0rw+(z0rw+norminv(p,0,1))/(1-arw*(z0rw+norminv(p,0,1))));
a2rw=normcdf(z0rw+(z0rw+norminv(1-p,0,1))/(1-arw*(z0rw+norminv(1-p,0,1))));

% sort bootstrap values to find confidence limits

clear M1s M2s mr2 rws
M1s=sort(M1b(2:B+1));
M2s=sort(M2b(2:B+1));
rs=sort(r(2:B+1));
rws=sort(rw(2:B+1));

clear lo hi M1lo M1hi M2lo M2hi rlo rhi rwlo rwhi
M1lo=max(floor(B*a1M1),1);
M1hi=ceil(B*a2M1);
M2lo=max(floor(B*a1M2),1);
M2hi=ceil(B*a2M2);
rlo=max(floor(B*a1r),1);
rhi=ceil(B*a2r);
rwlo=max(floor(B*a1rw),1);
rwhi=ceil(B*a2rw);

%
% sort influential cases
%

clear bigIM1 bigIM2 indIM1 indIM2
[bigIM1,indIM1]=sort(IM1);
[bigIM2,indIM2]=sort(IM2);

% **********************
%
% post fit processing and grafix
%
% **********************


% plot line fit

dx=max(data(:,1))-min(data(:,1));
dy=max(data(:,2))-min(data(:,2));
xind=min(data(:,1))-dx*0.2:dx/20:max(data(:,1))+dx*0.2;

for j=1:length(xind)
    yind(j)=xind(j)*M2b(1)+M1b(1);
end
p1=plot(xind,yind);
set(p1,'linewidth',3);
grid


fprintf('\n\n\n*************** RESULTS *****************\n\n');
fprintf('           Parameter and 95%% confidence limits\n\n');
fprintf('Line slope            = %e, %e to %e\n',M2b(1),M2s(M2lo),M2s(M2hi));
fprintf('Y-intercept           = %e, %e to %e\n',M1b(1),M1s(M1lo),M1s(M1hi));
fprintf('Linear correlation, r = %5.3f, %5.3f to %5.3f\n',r(1),rs(rlo),rs(rhi));
fprintf('Weighted....       rw = %5.3f, %5.3f to %5.3f\n\n',rw(1),rws(rwlo),rws(rwhi));
fprintf('Mean Absolute Value of Weighted Deviates, MAWD = %5.3f\n',mawd);
fprintf('Objective function; Initial value = %f, Final value = %f\n\n',Forig,Ffinal);
fprintf('___________________________________________________\n\n\n');
if isempty(outind)
    fprintf('No outliers were detected\n\n');
else
    fprintf('Outlier test positive at the 95%% level for ...\n\n');
    for j=1:length(outind)
      fprintf('Data point %d, x = %e, y = %e\n',outind(j),data(outind(j),xj),data(outind(j),yj));
    end
end
fprintf('\n___________________________________________________\n\n\n');
fprintf('Influence of Cases\n\n');
fprintf('Influence parameter is the ratio of the change in model parameter\n');
fprintf('caused by deleting a data point from the regression to the parameter\n');
fprintf('standard error. Values larger than 1 are influential cases.\n\n');
fprintf('Top 5 influential cases for slope\n');
for j=N:-1:N-4
    fprintf('Case # %d, Influence = %5.2f\n',indIM2(j),bigIM2(j));
end
fprintf('\nTop 5 influential cases for intercept\n');
for j=N:-1:N-4
    fprintf('Case # %d, Influence = %5.2f\n',indIM1(j),bigIM1(j));
end

% plot bootstrap histograms

figure(2)
clf
subplot(211)
hist(M2b,B/10)
axis manual
hold on
plot([M2b(1) M2b(1)],[0 B/2],'r');
plot([M2s(M2lo) M2s(M2lo)],[0 B/2],'r');
plot([M2s(M2hi) M2s(M2hi)],[0 B/2],'r');
xlabel('Line slope')
yS=['Number of ',num2str(B),' bootstraps'];
ylabel(yS)
title('Bootstrap replications')
subplot(212)
hist(M1b,B/10)
axis manual
hold on
plot([M1b(1) M1b(1)],[0 B/2],'r');
plot([M1s(M1lo) M1s(M1lo)],[0 B/2],'r');
plot([M1s(M1hi) M1s(M1hi)],[0 B/2],'r');
xlabel('Y-intercept')
ylabel(yS)

figure(3)
clf
subplot(211)
hist(r,B/10)
axis manual
hold on
plot([r(1) r(1)],[0 B/2],'r');
plot([rs(rlo) rs(rlo)],[0 B/2],'r');
plot([rs(rhi) rs(rhi)],[0 B/2],'r');
xlabel('Correlation coefficient, r')
ylabel(yS)
subplot(212)
hist(rw,B/10)
axis manual
hold on
plot([rw(1) rw(1)],[0 B/2],'r');
plot([rws(rwlo) rws(rwlo)],[0 B/2],'r');
plot([rws(rwhi) rws(rwhi)],[0 B/2],'r');
xlabel('Weighted Correlation, rw')
ylabel(yS)

% outlier and influence plots

figure(4)
clf
subplot(311)
hist(rstud)
hold on
plot([cv cv],[0 N*0.8],'r');
plot([-cv -cv],[0 N*0.8],'r');
xlabel('Studentized Residuals')
title('Outlier Test')
subplot(312)
hist(IM2)
title('Influence of Cases')
xlabel('Influence on Slope')
subplot(313)
hist(IM1)
xlabel('Influence on Intercept')
