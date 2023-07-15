function stats = exploreData(x)
%EXPLOREDATA 
% see:
%    https://www.itl.nist.gov/div898/handbook/eda/eda.htm

% for testing:
%x = 20+randn(100,1)*10;
%fourplot(x)

[x,~] = prepareCurveData(x,x);

% is the data discrete or continuous?
stats.continuous = true;
if isempty(setdiff(x,floor(x))), stats.continuous = false; end

%TODO: add options for Bernoulli, etc., for discrete data

% basic statistics
stats.N         = numel(x);
stats.Nunique   = numel(unique(x));
stats.mean      = mean(x,'omitnan');
stats.std       = std(x,'omitnan');
stats.median    = median(x,'omitnan');
stats.mode      = mode(round(x,2));
stats.min       = min(x);
stats.max       = max(x);
stats.var       = var(x);

% test for a few common distributions, then test all and rank
% (the 'best fit' for small samples can sometimes mislead)

stats.gof_test  = 'chi2gof';

% is the data normally distributed?
[h,p1] = chi2gof(x);
if h == false; stats.normal = true; else; stats.normal = false; end
if isnan(p1); stats.normal = false; end

% is the data uniformly distributed?
[h,p2] = chi2gof(x,'cdf',{@unifcdf,min(x),max(x)});
if h == false; stats.uniform = true; else; stats.uniform = false; end
if isnan(p2); stats.uniform = false; end

% is the data log-normally distributed?
stats.lognormal = false; p3 = nan;
if all(x>0); [h,p3] = chi2gof(x,'CDF',fitdist(x,'Lognormal'));
   if h == false; stats.lognormal = true; end
   if isnan(p3); stats.lognormal = false; end
end

% is the data exponentially distributed?
stats.exponential = false; p4 = nan;
if all(x>0); [h,p4] = chi2gof(x,'CDF',fitdist(x,'Exponential'));
   if h == false; stats.exponential = true; end
   if isnan(p4); stats.exponential = false; end
end

stats.normal_p      = p1;
stats.uniform_p     = p2;
stats.lognormal_p   = p3;
stats.exponential_p = p4; clear p1 p2 p3 p4 h

% fit (and rank) all available distributions
stats.dists     = allfitdist(x,'NLogL','PDF');

% various figures;
figure; title('histogram'); hold on;
histogram(x); xlabel('data'); ylabel('count');

if stats.normal == true; figure; probplot(x); end
if stats.lognormal == true; figure; probplot('lognormal',x); end
if stats.exponential == true; figure; probplot('exponential',x); end
%     if stats.uniform == true; figure; probplot(x,@unifpdf,min(x),max(x)); end
%         probplot({@unifpdf,min(x),max(x)},x)

figure; ecdf(x,'Bounds','on'); hold on; xx = linspace(min(x),max(x));
if stats.normal == true
   plot(xx,normcdf(xx,mean(x),std(x))); title('normal');
elseif stats.lognormal == true
   plot(xx,logncdf(xx,mean(log(x)),std(log(x)))); title('lognormal');
elseif stats.exponential == true
   plot(xx,expcdf(xx,mean(x))); title('exponential');
elseif stats.uniform == true
   plot(xx,unifcdf(xx,min(x),max(x))); title('uniform');
end
legend('empirical','+95% CI','-95% CI','theoretical','location','best');

% visual inspection of the 4 assumptions of univariate stat. analysis
stats2          = fourplot(x);
stats.Q25       = stats2.Q25;
stats.Q50       = stats2.Q50;
stats.Q75       = stats2.Q75;
stats.IQR       = stats2.IQR;
stats.isoutlier = stats2.IsOutlier;
stats.sorted    = stats2.SortedValues;



