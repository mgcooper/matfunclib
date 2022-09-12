%
% This code is provided as an electronic supplement to the G-cubed
% article on non-linear curve fitting, "Application of Maximum Likelihood
% and Bootstrap methods to non-linear curve-fit problems in geochemistry"
% by R. A. Sohn and W. Menke.
%
% Script to perform non-linear maximum likelihood inversion
% of crystal-melt partition coefficients from elastic moduli.
%
% The governing equation and basic principles are laid out in
% Blundy and Wood, Nature, 372, 452-454, 1994.
%
% x,y data with variable y errors are read in, and 3 parameters
% are estimated.
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
%      NOTE: This script calls 5 functions; linLS, rxy, MLEiter_v2, getf,
%            and getgradf. These are also Matlab .m files that must be loaded
%            into the same directory as this script so they
%            can be accessed by the code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% RAS 8/01
%

% set constants

Na=6.022e23;	% Avogadro's number
R=8.314;	% Gas constant, g-moles-joules

% read in z,y data pairs

fprintf('Data file must have 3 columns; x, y, std-y\n');
inpS=input('Data file name ?','s');
f1=fopen(inpS,'r');
data=fscanf(f1,'%f %f %f',[3 Inf]);
data=data';
[N,col]=size(data);
fclose(f1);

% automatic convergence parameter set as 1/1000 of the mean measurement error

em=mean(data(:,3));
epc=em/(1000);

% set convergence parameter

fprintf('Automatically selected convergence parameter is %e\n\n',epc);
chc=input('Enter desired convergence parameter or <return> to accept above value');
if isempty(chc) ~= 1
    if chc < 0
      error('Convergence parameter must be positive');
    end
    epc=chc;
end

% plot data

figure(1)
clf
plot(data(:,1),data(:,2),'o');

hold on

M=N+3;	% number of parameters in x vector

% needed to plot errors below

xvar=zeros(M,1);
xvar(1:N)=data(:,3).^2; % z (or x-axis) variance


% plot error bars

for j=1:N
    ey=[data(j,2)-sqrt(xvar(j)), data(j,2)+sqrt(xvar(j))];
    plot([data(j,1), data(j,1)],ey)
end

% get first guess of model parameters to estimate

D0i=input('Input initial guess for strain compensated partition coefficient, D0 ');
D0e=input('Input estimate of 1-sigma error on this guess ');
r0i=input('Input initial guess for optimum lattice site radius, r0 (m) ');
r0e=input('Input estimate of 1-sigma error on this guess ');
Ei=input('Input initial guess for Youngs modulus of host crystal, E (Pa) ');
Ee=input('Input estimate of 1-sigma error on this guess ');
T=input('Input temperature for fit, K ');
T=1653.15;

% get bootstrapping (error estimation) info

B=input('How many bootstrap samples for error estimates ?\n');

if isempty(B) || B < 0 || B > 6000
    error('Must enter a positive integer number < 6000');
elseif B==0
    bsf=1;
else
    bsf=B+1;
end

% initialize arrays and begin inversions and bootstrapping

D0b=zeros(bsf,1);	% storing estimates, first entry is estimate
from true data
r0b=zeros(bsf,1);
Eb=zeros(bsf,1);

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
        bi=ceil(rand(N,1)*N);
        bdata=data((bi),:);
        sameflag=0;
        if bi-bi(1)==zeros(N,1)  % if bootstrap sample is one point repeated...
          sameflag=1;
        end
      end     % endwhile
    end

% form x-vector and begin iterating on solution

    xap=zeros(M,1);
    xap(1:N)=bdata(:,2);
    xap(N+1)=D0i;
%  xap(N+2)=Ei;
    xap(N+2)=Ei/10^10;
%  xap(N+3)=r0i;
    xap(N+3)=r0i*10^10;
    covx=zeros(M,M);	% form covariance matrix, prior
    xvar(1:N)=bdata(:,3).^2;
    xvar(N+1)=D0e^2;
%  xvar(N+2)=Ee^2;
    xvar(N+2)=(Ee/10^10)^2;
%  xvar(N+3)=r0e^2;
    xvar(N+3)=(r0e*10^10)^2;
    covx=diag(xvar);
    epsilon=zeros(size(xap));
    epsilon(1:N)=ones(N,1)*epc;  % vector of eps values for each x element
    epsilon(N+1)=D0e/1000;
    epsilon(N+2)=Ee/(10^10)/1000;
    epsilon(N+3)=r0e*(10^10)/1000;
    xpre=xap; % set predicted to prior for first pass
    Z=[xpre; bdata(:,1)*10^10; T];	% vector with all values need for gradient calc

    if bs==0
      sig2iv=getf(Z,N,M,3);	% evaluate function to get initial variance
      sig2i=sqrt(sum(sig2iv.^2));
    end

    xpost=MLEiter_v2(xap,xpre,epsilon,covx,Z,N,M,3);	% call iterative solver

    D0b(bs+1)=xpost(N+1);
    Eb(bs+1)=xpost(N+2)*10^10; % save values into storage vectors
    r0b(bs+1)=xpost(N+3)*10^(-10);

    Zo=[xpost; bdata(:,1)*10^10; T];	% solution vector

    if bs==0
      sig2ov=getf(Zo,N,M,3);	% evaluate function to get final variance
      sig2o=sqrt(sum(sig2ov.^2));
    end

    bs=bs+1;	% increment bootstrap counter

end	% end while bootstrap flag


% **********************
%
% find bootstrap estimate of standard error for slope and intercept
%
% **********************

clear D0bmn Ebmn r0bmn seD0 seE ser0

D0bmn=sum(D0b)/bsf;
Ebmn=sum(Eb)/bsf;
r0bmn=sum(r0b)/bsf;
seD0=sqrt(sum((D0b-D0bmn).^2)/(bsf-1)); % std. error of D0
seE=sqrt(sum((Eb-Ebmn).^2)/(bsf-1)); % std. error of E
ser0=sqrt(sum((r0b-r0bmn).^2)/(bsf-1)); % std. error of m2


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

jdata=zeros(N-1,3);
D0j=zeros(N,1);
Ej=zeros(N,1);
r0j=zeros(N,1);
ID0=zeros(N,1);	% influence of cases
IE=zeros(N,1); % influence of cases
Ir0=zeros(N,1);
clear Z xvar

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

% calculate jackknife parameters

    xap=zeros(M-1,1);
    xap(1:N-1)=jdata(:,2);
    xap(N)=D0i;
%  xap(N+1)=Ei;
    xap(N+1)=Ei/10^(10);
%  xap(N+2)=r0i;
    xap(N+2)=r0i*10^10;
    covx=zeros(M-1,M-1);      % form covariance matrix, prior
    xvar(1:N-1)=jdata(:,3).^2;
    xvar(N)=D0e^2;
%  xvar(N+1)=Ee^2;
    xvar(N+1)=(Ee/10^10)^2;
%  xvar(N+2)=r0e^2;
    xvar(N+2)=(r0e*10^10)^2;
    covx=diag(xvar);
    epsilon=zeros(size(xap));
    epsilon(1:N-1)=ones(N-1,1)*epc;  % vector of eps values for each x element
    epsilon(N)=D0e/1000;
    epsilon(N+1)=Ee/(10^10)/1000;
    epsilon(N+2)=r0e*(10^10)/1000;
    xpre=xap; % set predicted to prior for first pass
    Z=[xpre; jdata(:,1)*10^10; T];      % vector with all values need for gradient calc


    xpost=MLEiter_v2(xap,xpre,epsilon,covx,Z,N-1,M-1,3);      % call iterative solver

    D0j(j)=xpost(N);
    Ej(j)=xpost(N+1)*10^10; % save values into storage vectors
    r0j(j)=xpost(N+2)*10^(-10);

%
% calculate influence of cases, similar to Cook's distance
%

ID0(j)=((D0j(j)-D0b(1))^2)/seD0^2;
IE(j)=((Ej(j)-Eb(1))^2)/seE^2;
Ir0(j)=((r0j(j)-r0b(1))^2)/ser0^2;

end   % end for j loop forming jacknife samples

% calculate the acceleration...

D0m=mean(D0j);	% mean jackknife values
Em=mean(Ej);
r0m=mean(r0j);
clear atop abot aD0 aE ar0
atop=sum((D0m-D0j).^3);
abot=6*(sum((D0m-D0j).^2)^(3/2));
aD0=atop/abot;	% acceleration for D0
clear atop abot
atop=sum((Em-Ej).^3);
abot=6*(sum((Em-Ej).^2)^(3/2));
aE=atop/abot;	% acceleration for E
clear atop abot
atop=sum((r0m-r0j).^3);
abot=6*(sum((r0m-r0j).^2)^(3/2));
ar0=atop/abot;	% acceleration for r0

% now compute the bias correction...

% standard will be to use 95% confidence limits

a=0.025;	% confidence limit to calculate

clear z0D0 z0E z0r0
z0D0=norminv((length(find(D0b < D0b(1)))/B),0,1);
z0E=norminv((length(find(Eb < Eb(1)))/B),0,1);
z0r0=norminv((length(find(r0b < r0b(1)))/B),0,1);
clear a1D0 a2D0 a1E a2E a1r0 a2r0
a1D0=normcdf(z0D0+(z0D0+norminv(a,0,1))/(1-aD0*(z0D0+norminv(a,0,1))));
a2D0=normcdf(z0D0+(z0D0+norminv(1-a,0,1))/(1-aD0*(z0D0+norminv(1-a,0,1))));
a1E=normcdf(z0E+(z0E+norminv(a,0,1))/(1-aE*(z0E+norminv(a,0,1))));
a2E=normcdf(z0E+(z0E+norminv(1-a,0,1))/(1-aE*(z0E+norminv(1-a,0,1))));
a1r0=normcdf(z0r0+(z0r0+norminv(a,0,1))/(1-ar0*(z0r0+norminv(a,0,1))));
a2r0=normcdf(z0r0+(z0r0+norminv(1-a,0,1))/(1-ar0*(z0r0+norminv(1-a,0,1))));

% sort bootstrap values to find confidence limits

clear D0s Es r0s
D0s=sort(D0b(2:B+1));
Es=sort(Eb(2:B+1));
r0s=sort(r0b(2:B+1));

clear lo hi D0lo D0hi Elo Ehi r0lo r0hi
D0lo=max(floor(B*a1D0),1);
D0hi=ceil(B*a2D0);
Elo=max(floor(B*a1E),1);
Ehi=ceil(B*a2E);
r0lo=max(floor(B*a1r0),1);
r0hi=ceil(B*a2r0);

%
% sort influential cases
%

clear bigID0 bigIr0 bigIE indID0 indIr0 indIE
[bigID0,indID0]=sort(ID0);
[bigIE,indIE]=sort(IE);
[bigIr0,indIr0]=sort(Ir0);


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
 
yind(j)=D0b(1)*exp(-4*pi*Eb(1)*Na*((r0b(1)/2)*(xind(j)-r0b(1))^2+((xind(j)-r0b(1))^3)/3)/(R*T));
end
p1=plot(xind,yind);
set(p1,'linewidth',3);
grid


fprintf('\n\n\n*************** RESULTS *****************\n\n');
fprintf('           Parameter and 95%% confidence limits\n\n');
fprintf('Youngs modulus,           E = %e, %e to %e\n',Eb(1),Es(Elo),Es(Ehi));
fprintf('Optimum radius,          r0 = %e, %e to %e\n',r0b(1),r0s(r0lo),r0s(r0hi));
fprintf('Strain-comp part. coef., D0 = %e, %e to %e\n',D0b(1),D0s(D0lo),D0s(D0hi));
fprintf('\nVariance: initial = %e, final = %e, ratio = %e\n',sig2i,sig2o,sig2o/sig2i);
fprintf('\n*****************************************\n\n\n');
fprintf('Influence of Cases\n\n');
fprintf('Influence parameter is the ratio of the change in model parameter\n');
fprintf('caused by deleting a data point from the regression to the parameter\n');
fprintf('standard error. Values larger than 1 are influential cases.\n\n');
fprintf('Influence of cases\n');
for j=1:N
    fprintf('Case # %d, Influence on E = %5.2f, on r0 = %5.2f, on D0 = %5.2f\n',j,IE(j), Ir0(j),ID0(j));
end

% plot bootstrap histograms

figure(2)
clf
hist(D0b,B/10)
axis manual
hold on
plot([D0b(1) D0b(1)],[0 B/2],'r');
plot([D0s(D0lo) D0s(D0lo)],[0 B/2],'r');
plot([D0s(D0hi) D0s(D0hi)],[0 B/2],'r');
xlabel('Strain comp. partition coefficient, D0')
yS=['Number of ',num2str(B),' bootstraps'];
ylabel(yS)
title('Bootstrap replications')

figure(3)
clf
hist(Eb,B/10)
axis manual
hold on
plot([Eb(1) Eb(1)],[0 B/2],'r');
plot([Es(Elo) Es(Elo)],[0 B/2],'r');
plot([Es(Ehi) Es(Ehi)],[0 B/2],'r');
xlabel('Youngs modulus, E (Pa)')
ylabel(yS)

figure(4)
clf
hist(r0b,B/10)
axis manual
hold on
plot([r0b(1) r0b(1)],[0 B/2],'r');
plot([r0s(r0lo) r0s(r0lo)],[0 B/2],'r');
plot([r0s(r0hi) r0s(r0hi)],[0 B/2],'r');
xlabel('Optimum lattice radius, r0 (m)')
ylabel(yS)

% outlier and influence plots

figure(5)
clf
subplot(311)
hist(ID0)
title('Influence of Cases')
xlabel('Influence on D0')
subplot(312)
hist(IE)
xlabel('Influence on E')
subplot(313)
hist(Ir0)
xlabel('Influence on ro')
