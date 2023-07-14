function [b,xmin,alpha,D,h0] = myplfit(x,varargin)
%MYPLFIT power law fit
%
%  [b,xmin,alpha,D,h0] = myplfit(x,varargin)
%
% See also

% parse inputs
p = inputParser;
p.FunctionName = mfilename;
p.addRequired('x',@isnumeric);
p.addParameter('goftest','ks',@ischar);
p.addParameter('makeplot',true,@islogical);
p.parse(x, varargin{:});


% see ksboot - it's hidden in a weird folder in my fex path:

% NOTE: could try fmincon
% If you have the Optimization Toolbox, type "help fmincon." It does
% general minimization with constraints. You supply the negative likelihood
% or log-likelihood function for the problem you're trying to solve

% prep the data
[x,xmins,M,D,x0] = prepinput(x,p.goftest);

% find the best-fit xmin
for m = 1:M

   [cx,cf]  = plcdf(x,xmins(m));
   D(m,:)   = gofdist(cx,cf,p.goftest); % goodness of fit distance

   % i think here, once xmin,alpha known, bootstrap cf to get pval
end

% evaluate the best-fit distribution
[x,xmin,alpha,D,cx,cf,b,h0] = bestfitdist(x,xmins,D);

% plot the best-fit
if p.makeplot == true
   % this won't come out quite the same as bfra_gpfitb, i think b/c of
   % gpfit and gpcdf return slightly different results than plplot

   % there is something wrong with bfra_plplot
   % figure; bfra_plplot(x0,xmin,alpha);

   % because this works as expected
   figure; loglog(x,1-cx,'o'); hold on; loglog(x,1-cf);
end

% if we want to evaluate all the gof tests, do that here
if strcmp(p.goftest,'all')

   [x,xmin,alpha,D,cx,cf,b,h0] = allbestfit(D,p.goftest);

   if makeplot == true

      load('distinguishablecolors.mat','dc')

      figure; bfra_plplot(x0,xmin,alpha);

      % plot the ccdf with vlines at each taumin
      [F,X]    = ecdf(x0,'Function','survivor');
      h        = stairs(X,F,'LineWidth',1.5); hold on;
      set(gca,'YScale','log','XScale','log'); axis tight
      ylims    = ylim;

      for n = 1:numD
         p(n) = plot([allmins(n) allmins(n)],[ylims(1) ylims(2)],'Color',dc(n,:));
      end

      legend(p,testnames);

      %  [ADK,ADKn,ADKs,ADKsn] = AnDarksamtest(testsample)
   end

end


function [x,xmins,M,D,x0] = prepinput(x,goftest)

x        = sort(x);
x0       = x;
xmins    = unique(x);
M        = numel(x)-100;

if strcmp(goftest,'all')
   D     = nan(M,5);
else
   D     = nan(M,1);
end


function [cx,cf,alpha,xtr] = plcdf(x,xmin)

x     = x(x>=xmin);                 % truncate the data
N     = length(x);                  % sample size for z>zmin
lam   = N ./ sum( log(x./xmin) );   % mle to get alpha-1 (cdf exponent) eq. 3.1
cx    = (0:N-1)'./N;                % the empirical cdf
cf    = 1-(xmin./x).^lam;           % the theoretical cdf
% alpha = 1+1/lam;                    % plaw exponent
alpha = lam + 1;                    % plaw exponent
xtr   = x;                          % truncated data



function D = gofdist(cx,cf,goftest)

switch goftest
   case 'ks'
      %D  = max( abs(cf-cx) );       % standard ksdistance
      D  = ksdist(cx,cf);
   case 'ad'
      D  = addist(cx,cf);
   case 'cvm'
      D  = cvmdist(cx,cf);
   case 'kuiper'
      D  = kuiperdist(cx,cf);
   case 'wasser'
      D  = wasserdist(cx,cf);
   case 'all'
      D(1) = ksdist(cx,cf);
      D(2) = addist(cx,cf);
      D(3) = cvmdist(cx,cf);
      D(4) = kuiperdist(cx,cf);
      D(5) = wasserdist(cx,cf);
end


function [x,xmin,alpha,D,cx,cf,b,h0] = bestfitdist(x,xmins,D)

% choose the smallest k-s distance and get the final estimates
D1    = D(:,1);      % use k-s as default, which is column 1
Dmin  = min(D1);
xmin  = xmins(find(D1<=Dmin,1,'first'));

[cx,cf,alpha,x] = plcdf(x,xmin);

b     = 1+1/alpha;

% test hypothesis
h0    = kstest2(cx,cf); % null = from same dist, 1=not same, 0 = same


function [bb,xxmin,aalpha,DD] = allbestfit(D,goftest);

if strcmp(goftest,'all')
   % find the min across each gof measure
   minD     = min(D);
   numD     = numel(minD);
   minidx   = nan(numD,1);
   allmins  = nan(numD,1);

   for n = 1:numD
      minidx(n)   = find(D(:,n)<=minD(n),1,'first');
      allmins(n)  = xmins(minidx(n));
   end

   %  testnames = {'KS','KSMatlab','KS2samp','KSKsamp','AD','CVM','KUIP','WASS'};
   testnames   = {'KS','KSKsamp','AD','CVM','KUIP','WASS'};
   D           = array2table(D,'VariableNames',testnames);
end


function D = getadtestk(cx,cf)

% anderson-darling k-sample
onesv       = ones(size(cf)); % vector of ones representing sample 1
testsample  = [vertcat(cx,cf) vertcat(onesv,2.*onesv)];
D           = adtestk(testsample);




%    % NOTES FOR REFERENCE
%
%    % this works, but no reason to use it, other than to also see how
%    % alternative tests could be used in place of it
%    [~,~,D(m)]  = kstest2(cx,cf)
%
%    % to use kstest2 as expected, we'd need to make actual data, not the cdf
%    zdat        = plrand(10000,lam+1,xmin);
%    [~,~,ksd]   = kstest2(zdat,z);
%
%    % note that this would be the dumb way to make the theoretical cdf
%    [F,x]       = ecdf(zdat);
%    F           = F(x>min(z) & x<max(z));
%    x           = x(x>min(z) & x<max(z));
%    figure; loglog(z,1-cx); hold on; plot(x,1-F); hold on; plot(z,1-cf);
%    legend('F (data)','F (plrand)','F (cdf eqn)');
%
%    % NOTE: this is important, this shows how, if you generate random pl
%    % data, then truncate it, THEN fit the cdf, you get the massive fall-off
%    % in the tail
%    zdat  = plrand(10000,lam+1,xmin);
%    zdat  = zdat(zdat>min(z) & zdat<max(z));
%    [F,x] = ecdf(zdat);
%    figure; loglog(x,1-F); hold on; plot(z,1-cf)
%
%    % but will kstest get it right?
%
%
%    zdat  = (1-rand(10000,1)).^(-1/lam);
%    [~,~,ksd] = kstest2(zdat,z)
%    [~,~,ksd] = kstest2(F,cf)
%
%    [~,~,ksd] = kstest([cf cx])
%
%    figure; loglog(z,1-cx,'o'); hold on; loglog(z,1-cf);
%
%    a     = lam+1;
%    %    a1    = 1 + 1/lam;   % this should be the correct alpha
%    %    a2    = 1/(lam-1);   % but when this is converted from alpha to k it leads to what gpfit returns as k
%    b     = bfra_conversions(a,'alpha','b');
%    k     = bfra_conversions(a,'alpha','k');
%    sig   = xmin*(b-1)/(b-2);
%    c     = gpcdf(z,k,sig,xmin);
%    c     = gpcdf(z,k,sig,xmin,'upper');
%    hold on; loglog(z,c,'g')
%
%    c     = gpcdf(z+xmin,k(m),pd.sigma,xmin,'upper');
%    hold on; plot(z+xmin,c,'g')
%
%    % NOTE: a is 1/(a-1)
%
%
%
%    %z     = z(z>tau(n));
%    %xn    = sort(tau(tau>tau(n))-tau(n));
%    pd    = fitdist(z,'GeneralizedPareto');
%    k(m)  = pd.k;
%    b(m)  = bfra_conversions(k(m),'k','b');
%    al(m)  = bfra_conversions(k(m),'k','alpha');
%
%
%    c     = gpcdf(xn+x(m),k(m),pd.sigma,x(m),'upper');
%
%    hold on; plot(xn+x(m),c,'m')
%
%    [~,~,ksd(m)] = kstest(F,c)
%
%
%    c     = gpcdf(xn,k(m),pd.sigma,x(m),'upper');
%    r     = plrand
%    xn    = xn(c<1);
%    c     = c(c<1);
%    hold on; plot(xn,c,'m')
