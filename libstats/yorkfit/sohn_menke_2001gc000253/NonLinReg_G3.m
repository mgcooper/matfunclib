%
% This code is provided as an electronic supplement to the G-cubed
% article on non-linear curve fitting, "Application of Maximum Likelihood
% and Bootstrap methods to non-linear curve-fit problems in geochemistry"
% by R. A. Sohn and W. Menke.
%
% This is a Matlab script to perform maximum likelihood inversion of a straight
% line to x- and y- data, when x- and y- are considered random variables
% with known errors. Data is expected as 4 columns; (1) x, (2) y, (3) std-x,
% (4) std-y. When non-zero values are provided for both columns 3 and 4 the
% script uses the non-linear, Gaussian based Max. Likelihood method described
% in the G-cubed article to find a solution. When either column 3 or 4 contains
% all zeros, the code defaults to linear Least Squares methods.
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
% RAS 2/00
%
% to follow nomenclature of Menke use z- and y- as data variables
% m1 for slope, m2 for y-intercept.
%

clear

% PARAMETER FOR COVERGENCE ****************

%epc=1.e-4;	% epsilon for perturbation cutoff

% first step is to form x-vector, consisting of data and first guess
% for slope and intercept; x=[z,y,m]-transpose
%
% read in z,y data pairs
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

% determine if dataset is double or single error

if data(:,3)==zeros(N,1)
    de=0;	% not double error dataset, x is index, y is variable
    xi=1;
    yi=2;
elseif data(:,3)~=zeros(N,1) && data(:,4)==zeros(N,1)
    de=0;	% not double error dataset, y is index, x is variable
    xi=2;
    yi=1;
else
    de=1;	% double error dataset
    xi=1;
    yi=2;
end

% set convergence parameter for iterative solution if double error

if de==1
    fprintf('Automatically selected convergence parameter is %e\n\n',epc);
    chc=input('Enter desired convergence parameter or <return> to accept above value');
    if isempty(chc) ~= 1
      if chc < 0
        error('Convergence parameter must be positive');
      end
      epc=chc;
    end
end

figure(1)
clf
plot(data(:,1),data(:,2),'o');

hold on

M=2*N+2;	% number of parameters in x vector

% needed to plot errors below

xvar=zeros(M,1);
xvar(1:N)=data(:,3).^2; % z (or x-axis) variance
xvar(N+1:2*N)=data(:,4).^2;        % y variance


% plot error bars

for j=1:N
    ez=[data(j,1)-sqrt(xvar(j)), data(j,1)+sqrt(xvar(j))];
    ey=[data(j,2)-sqrt(xvar(N+j)), data(j,2)+sqrt(xvar(N+j))];
    plot(ez,[data(j,2), data(j,2)])
    plot([data(j,1), data(j,1)],ey)
end

% get prior information for regression

m1pc=input('\nInitial values for slope, <cr> for automatic : ');
m2pc=input('\nInitial values for intercept, <cr> for automatic : ');
fprintf('\n\nSlope constraints:\n\n<cr>=unconstrained\n<0>=hard constraint\n ');
m1cc=input('or input user defined standard deviation : ');
fprintf('\n\nIntercept constraints:\n\n<cr>=unconstrained\n<0>=hard constraint\n ');
m2cc=input('or input user defined standard deviation : ');


if ~isempty(m1pc)
    M1=m1pc;
end

if ~isempty(m2pc)
    M2=m2pc;
end

if ~isempty(m2cc)
    if m2cc==0
      SM2=1e-10;
    else
      SM2=m2cc;
    end
end

if ~isempty(m1cc)
    if m1cc==0
      SM1=1e-10;
    else
      SM1=m1cc;
    end
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

bswf=input('Do you wish to adjust the probabilities of individual samples for bootstrapping ? (1=yes, <carriage return>=no ');
if isempty(bswf)~=1
    wfS=input('Input name of file with probability weights ','s');
    fwfid=fopen(wfS,'r');
    bswts=fscanf(fwfid,'%d');
    Nb=sum(bswts);
else
    Nb=N;
end

% assign data indices to weighted probability index marker array
wtdi=zeros(Nb,1);
wti=1;
if Nb==N
    wtdi=1:1:N;
else
    for wj=1:N
      wtdi(wti:bswts(wj)+wti-1)=wj;
      wti=wti+bswts(wj);
    end
end

%
% initialize arrays and begin bootstrapping
%

m1b=zeros(bsf,1);	% storing estimates, first entry is estimate
from true data
m2b=zeros(bsf,1);
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
      bdata=data;
    else
      sameflag=1;
      while sameflag==1
        bi=ceil(rand(N,1)*Nb);
        bdata=data(wtdi(bi),:);
        sameflag=0;
        if bi-bi(1)==zeros(N,1)  % if bootstrap sample is one point repeated...
          sameflag=1;
        end
      end     % endwhile
    end

% do ordinary or weighted least squares to get first guess of model
% parameters and variance


    [mest,mvar,Xhat]=linLS(bdata,xi,yi);

    if bs==0
      xdel=zeros(N,1);
      rstud=zeros(N,1);
      hatdiag=zeros(N,1);
      [rtemp,mz,SZZ]=rxy(bdata,xi,yi);    % unweighted estimate
      xdel=bdata(:,yi)-Xhat;	% residuals
      sighat=sqrt((sum(xdel))/(N-2)); % unbiased posterior variance estimate
      hatdiag=((bdata(:,xi)-mz).^2)/SZZ+1/N;
      rstud=xdel./(sighat*sqrt(ones(N,1)-hatdiag)); % stud. res
      rstud=rstud.*sqrt((ones(N,1)*(N-3))./(ones(N,1)*N-2-rstud.^2)); % ext. stud. res.
    end


% calculate correlation coefficient, both with and without weighting


    rdata=bdata;
    [rw(bs+1),mzw,SZZw]=rxy(rdata,xi,yi);	% call rxy function for
weighted estimate
    rdata(:,3:4)=ones(N,2);
    [r(bs+1),mz,SZZ]=rxy(rdata,xi,yi);	% unweighted estimate
% save if first time through
    if bs==0
      corr=r(bs+1);
      corrw=rw(bs+1);
    end


% get a priori paramters and model variance

    if ~isempty(m2pc)
      m2=M2;
    else
      m2=mest(1);
    end

    if ~isempty(m1pc)
      m1=M1;
    else
      m1=mest(2);
    end

    if isempty(m1cc)
      m1var=mvar(2);
    else
      m1var=SM1;
    end

    if isempty(m2cc)
      m2var=mvar(1);
    else
      m2var=SM2;
    end

    m1b(bs+1)=m1; % save values into storage vectors
    m2b(bs+1)=m2;


    if de==1	% if this is a double error dataset, then recalculate line

      xap=zeros(M,1);
      xap(1:N)=bdata(:,1);
      xap(N+1:2*N)=bdata(:,2);
      xap(2*N+1)=m1;
      xap(2*N+2)=m2;
      covx=zeros(M,M);	% form covariance matrix, prior
      xvar=zeros(M,1);
      xvar(1:N)=bdata(:,3).^2; % z (or x-axis) variance
      xvar(N+1:2*N)=bdata(:,4).^2;        % y variance
      xvar(2*N+1)=m1var;      % m1 variance
      xvar(2*N+2)=m2var;  % m2 variance
      covx=diag(xvar);
      epsilon=ones(size(xap))*epc;  % vector of eps values for each x element
      xpre=xap; % set predicted to prior for first pass


      xpost=MLEiter(xap,xpre,epsilon,covx);	% call iterative solver


      m1b(bs+1)=xpost(2*N+1); % save values into storage vectors
      m2b(bs+1)=xpost(2*N+2);

% **************************
%
% calculate Mean Square of Weighted Deviates (MSWD), and studentized residuals
% if first time through
%
% **************************

      if bs==0
        clear xdel mswd dxy sighat rstud hatdiag Xhat0
        Xhat0=xpost; % save for later comparison with jacknife values
        xdel=zeros(2*N,1); % adjustment of each data point divided by
prior variance
        dxy=zeros(N,1); % weighted Euclidean distance of data adjustment
        rstud=zeros(N,1); % studentized (externally) residual
        hatdiag=zeros(N,1); % diagonal of hat matrix
        xdel=(xap(1:2*N)-xpost(1:2*N)).^2; % squared variation of each x,y point
        sighat=sqrt((sum(xdel(N+1:2*N)))/(N-2)); % unbiased posterior
variance estimate
        hatdiag=((xap(1:N)-mz).^2)/SZZ+1/N;
 
rstud=(xap(N+1:2*N)-xpost(N+1:2*N))./(sighat*sqrt(ones(N,1)-hatdiag));
% stud. res.
        rstud=rstud.*sqrt((ones(N,1)*(N-3))./(ones(N,1)*N-2-rstud.^2));
% ext. stud. res.
        xdel=xdel./xvar(1:2*N);	% weighted by inverse variance
        dxy=xdel(1:N)+xdel(N+1:2*N);	% square of total variation
        mswd=mean(dxy);	% mean square of weighted deviates

% test residuals for normal distribution

        xres=xpost(1:N)-xap(1:N);	% x residuals
        yres=xpost(N+1:2*N)-xap(N+1:2*N);	% y residuals
        resdata(:,1)=xres;
        resdata(:,2)=yres;
        resdata(:,3)=data(:,3);
        resdata(:,4)=data(:,4);
        [Xord,Yord,Rk,Rx,Ry] = NrmTst(resdata);
      end


    end	% end if double error case

    bs=bs+1;	% increment bootstrap counter

end	% end while bootstrap flag


% **********************
%
% find bootstrap estimate of standard error for slope and intercept
%
% **********************

clear m1bmn m2bmn sem1 sem2

m1bmn=sum(m1b)/bsf;
m2bmn=sum(m2b)/bsf;
sem1=sqrt(sum((m1b-m1bmn).^2)/(bsf-1)); % std. error of m1
sem2=sqrt(sum((m2b-m2bmn).^2)/(bsf-1)); % std. error of m2


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
m1j=zeros(N,1);
m2j=zeros(N,1);
rj=zeros(N,1);
rjw=zeros(N,1);
Im1=zeros(N,1);	% influence of cases
Im2=zeros(N,1); % influence of cases

fprintf('\nJackknifing to correct confidence limits for error acceleration\n');
fprintf('Working jackknife sample #     ');
for j=1:N
    fprintf('\b\b\b\b%4d',j);
    jcount=1;
    for k=1:N	% form jth jackknife sample
      if k~=j
        jdata(jcount,:)=data(k,:);
        jcount=jcount+1;
      end
    end

% calculate jackknife correlation coefficients

    rwj(j)=rxy(jdata,xi,yi);	% weighted rxy calc
    jdata(:,3:4)=ones(N-1,2);
    rj(j)=rxy(jdata,xi,yi);	% unweighted

% calculate jackknife slope and intercept
% first do linear least squares to get prior parameter estimates

    [mest,mvar,Xhat]=linLS(jdata,xi,yi);
    m1=mest(2);
    m2=mest(1);
    m1var=mvar(2);
    m2var=mvar(1);

    if de~=1   % if not a double error dataset
      m1j(j)=m1;
      m2j(j)=m2;
    else		% if it is a double error set go non-linear
      xap=zeros(M-2,1);
      xap(1:N-1)=jdata(:,1);
      xap(N:2*(N-1))=jdata(:,2);
      xap(2*(N-1)+1)=m1;
      xap(2*(N-1)+2)=m2;	% form prior estimate of x
      covx=zeros(M-2,M-2);
      xvar=zeros(M-2,1);
      xvar(1:N-1)=jdata(:,3).^2; % z (or x-axis) variance
      xvar(N:2*(N-1))=jdata(:,4).^2;        % y variance
      xvar(2*(N-1)+1)=m1var;      % m1 variance
      xvar(2*(N-1)+2)=m2var;  % m2 variance
      covx=diag(xvar);	% form prior covariance matrix of x
      epsilon=ones(size(xap))*epc;  % vector of eps values for each x element
      xpre=xap; % set predicted to prior for first pass

      xpost=MLEiter(xap,xpre,epsilon,covx);       % call iterative solver

      m1j(j)=xpost(2*(N-1)+1); % save values into storage vectors
      m2j(j)=xpost(2*(N-1)+2);

    end  % end for if double error dataset

%
% calculate influence of cases, similar to Cook's distance
%

Im1(j)=((m1j(j)-m1b(1))^2)/sem1^2;
Im2(j)=((m2j(j)-m2b(1))^2)/sem2^2;

end   % end for j loop forming jacknife samples

% calculate the acceleration...

m1m=mean(m1j);	% mean jackknife values
m2m=mean(m2j);
rm=mean(rj);
rwm=mean(rwj);
clear atop abot am1 am2 ar arw
atop=sum((m1m-m1j).^3);
abot=6*(sum((m1m-m1j).^2)^(3/2));
am1=atop/abot;	% acceleration for m1
clear atop abot
atop=sum((m2m-m2j).^3);
abot=6*(sum((m2m-m2j).^2)^(3/2));
am2=atop/abot;	% acceleration for m2
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

a=0.025;	% confidence limit to calculate

clear z0m1 z0m2 z0r z0rw
z0m1=norminv((length(find(m1b < m1b(1)))/B),0,1);
z0m2=norminv((length(find(m2b < m2b(1)))/B),0,1);
z0r=norminv((length(find(r < r(1)))/B),0,1);
z0rw=norminv((length(find(rw < rw(1)))/B),0,1);
clear a1m1 a2m1 a1m2 a2m2 a1r a2r a1rw a2rw
a1m1=normcdf(z0m1+(z0m1+norminv(a,0,1))/(1-am1*(z0m1+norminv(a,0,1))));
a2m1=normcdf(z0m1+(z0m1+norminv(1-a,0,1))/(1-am1*(z0m1+norminv(1-a,0,1))));
a1m2=normcdf(z0m2+(z0m2+norminv(a,0,1))/(1-am2*(z0m2+norminv(a,0,1))));
a2m2=normcdf(z0m2+(z0m2+norminv(1-a,0,1))/(1-am2*(z0m2+norminv(1-a,0,1))));
a1r=normcdf(z0r+(z0r+norminv(a,0,1))/(1-ar*(z0r+norminv(a,0,1))));
a2r=normcdf(z0r+(z0r+norminv(1-a,0,1))/(1-ar*(z0r+norminv(1-a,0,1))));
a1rw=normcdf(z0rw+(z0rw+norminv(a,0,1))/(1-arw*(z0rw+norminv(a,0,1))));
a2rw=normcdf(z0rw+(z0rw+norminv(1-a,0,1))/(1-arw*(z0rw+norminv(1-a,0,1))));

% sort bootstrap values to find confidence limits

clear m1s m2s mr2 rws
m1s=sort(m1b(2:B+1));
m2s=sort(m2b(2:B+1));
rs=sort(r(2:B+1));
rws=sort(rw(2:B+1));

clear lo hi m1lo m1hi m2lo m2hi rlo rhi rwlo rwhi
m1lo=max(floor(B*a1m1),1);
m1hi=ceil(B*a2m1);
m2lo=max(floor(B*a1m2),1);
m2hi=ceil(B*a2m2);
rlo=max(floor(B*a1r),1);
rhi=ceil(B*a2r);
rwlo=max(floor(B*a1rw),1);
rwhi=ceil(B*a2rw);

%
% sort influential cases
%

clear bigIm1 bigIm2 indIm1 indIm2
[bigIm1,indIm1]=sort(Im1);
[bigIm2,indIm2]=sort(Im2);

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
    yind(j)=xind(j)*m1b(1)+m2b(1);
end
p1=plot(xind,yind);
set(p1,'linewidth',3);
grid


fprintf('\n\n\n*************** RESULTS *****************\n\n');
fprintf('           Parameter and 95%% confidence limits\n\n');
fprintf('Line slope            = %e, %e to %e\n',m1b(1),m1s(m1lo),m1s(m1hi));
fprintf('Y-intercept           = %e, %e to %e\n',m2b(1),m2s(m2lo),m2s(m2hi));
fprintf('Linear correlation, r = %5.3f, %5.3f to %5.3f\n',r(1),rs(rlo),rs(rhi));
fprintf('Weighted....       rw = %5.3f, %5.3f to %5.3f\n\n',rw(1),rws(rwlo),rws(rwhi));
if de==1
    fprintf('Mean Square of Weighted Deviates, MSWD = %5.3f\n\n',mswd);
end
fprintf('___________________________________________________\n\n\n');
if isempty(outind)
    fprintf('No outliers were detected\n\n');
else
    fprintf('Outlier test positive at the 95%% level for ...\n\n');
    for j=1:length(outind)
      fprintf('Data point %d, x = %e, y = %e\n',outind(j),data(outind(j),xi),data(outind(j),yi));
    end
end
fprintf('\n___________________________________________________\n\n\n');
fprintf('Influence of Cases\n\n');
fprintf('Influence parameter is the ratio of the change in model parameter\n');
fprintf('caused by deleting a data point from the regression to the parameter\n');
fprintf('standard error. Values larger than 1 are influential cases.\n\n');
fprintf('Top 5 influential cases for slope\n');
for j=N:-1:N-4
    fprintf('Case # %d, Influence = %5.2f\n',indIm1(j),bigIm1(j));
end
fprintf('\nTop 5 influential cases for intercept\n');
for j=N:-1:N-4
    fprintf('Case # %d, Influence = %5.2f\n',indIm2(j),bigIm2(j));
end

% plot bootstrap histograms

figure(2)
clf
subplot(211)
hist(m1b,B/10)
axis manual
hold on
plot([m1b(1) m1b(1)],[0 B/2],'r');
plot([m1s(m1lo) m1s(m1lo)],[0 B/2],'r');
plot([m1s(m1hi) m1s(m1hi)],[0 B/2],'r');
xlabel('Line slope')
yS=['Number of ',num2str(B),' bootstraps'];
ylabel(yS)
title('Bootstrap replications')
subplot(212)
hist(m2b,B/10)
axis manual
hold on
plot([m2b(1) m2b(1)],[0 B/2],'r');
plot([m2s(m2lo) m2s(m2lo)],[0 B/2],'r');
plot([m2s(m2hi) m2s(m2hi)],[0 B/2],'r');
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

% normal probability plots

figure(4)
clf
SRx=['R^2 = ',num2str(Rx)];
SRy=['R^2 = ',num2str(Ry)];
xh=plot(Rk,Xord,'ko');
set(xh,'MarkerFaceColor','k');
xlabel('Rankits')
ylabel('Ordered data')
title('Normal Test for X data')
ym=max(Xord);
text(-1.5,ym*0.85,SRx);

figure(5)
clf
yh=plot(Rk,Yord,'ko');
set(yh,'MarkerFaceColor','k');
xlabel('Rankits')
ylabel('Ordered data')
title('Normal Test for Y data')
ym=max(Yord);
text(-1.5,ym*0.85,SRy);
