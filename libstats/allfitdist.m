function [D, PD, h] = allfitdist(X, sortby, varargin)
   %ALLFITDIST Fit all valid parametric probability distributions to data.
   %   [D PD] = ALLFITDIST(DATA) fits all valid parametric probability
   %   distributions to the data in vector DATA, and returns a struct D of
   %   fitted distributions and parameters and a struct of objects PD
   %   representing the fitted distributions. PD is an object in a class
   %   derived from the ProbDist class.
   %
   %   [...] = ALLFITDIST(DATA,SORTBY) returns the struct of valid distributions
   %   sorted by the parameter SORTBY
   %        NLogL - Negative of the log likelihood
   %        BIC - Bayesian information criterion (default)
   %        AIC - Akaike information criterion
   %        AICc - AIC with a correction for finite sample sizes
   %
   %   [...] = ALLFITDIST(...,'DISCRETE') specifies it is a discrete
   %   distribution and does not attempt to fit a continuous distribution
   %   to the data
   %
   %   [...] = ALLFITDIST(...,'PDF') or (...,'CDF') plots either the PDF or CDF
   %   of a subset of the fitted distribution. The distributions are plotted in
   %   order of fit, according to SORTBY.
   %
   %   List of distributions it will try to fit
   %     Continuous (default)
   %       Beta
   %       Birnbaum-Saunders
   %       Exponential
   %       Extreme value
   %       Gamma
   %       Generalized extreme value
   %       Generalized Pareto
   %       Inverse Gaussian
   %       Logistic
   %       Log-logistic
   %       Lognormal
   %       Nakagami
   %       Normal
   %       Rayleigh
   %       Rician
   %       t location-scale
   %       Weibull
   %
   %     Discrete ('DISCRETE')
   %       Binomial
   %       Negative binomial
   %       Poisson
   %
   %   Optional inputs:
   %   [...] = ALLFITDIST(...,'n',N,...)
   %   For the 'binomial' distribution only:
   %      'n'            A positive integer specifying the N parameter (number
   %                     of trials).  Not allowed for other distributions. If
   %                     'n' is not given it is estimate by Method of Moments.
   %                     If the estimated 'n' is negative then the maximum
   %                     value of data will be used as the estimated value.
   %   [...] = ALLFITDIST(...,'theta',THETA,...)
   %   For the 'generalized pareto' distribution only:
   %      'theta'        The value of the THETA (threshold) parameter for
   %                     the generalized Pareto distribution. Not allowed for
   %                     other distributions. If 'theta' is not given it is
   %                     estimated by the minimum value of the data.
   %
   %   Note: ALLFITDIST does not handle nonparametric kernel-smoothing,
   %   use FITDIST directly instead.
   %
   %
   %   EXAMPLE 1
   %     Given random data from an unknown continuous distribution, find the
   %     best distribution which fits that data, and plot the PDFs to compare
   %     graphically.
   %        data = normrnd(5,3,1e4,1);         %Assumed from unknown distribution
   %        [D PD] = allfitdist(data,'PDF');   %Compute and plot results
   %        D(1)                               %Show output from best fit
   %
   %   EXAMPLE 2
   %     Given random data from a discrete unknown distribution, with frequency
   %     data, find the best discrete distribution which would fit that data,
   %     sorted by 'NLogL', and plot the PDFs to compare graphically.
   %        data = nbinrnd(20,.3,1e4,1);
   %        values=unique(data); freq=histc(data,values);
   %        [D PD] = allfitdist(values,'NLogL','frequency',freq,'PDF','DISCRETE');
   %        PD{1}
   %
   %  EXAMPLE 3
   %     Although the Geometric Distribution is not listed, it is a special
   %     case of fitting the more general Negative Binomial Distribution. The
   %     parameter 'r' should be close to 1. Show by example.
   %        data=geornd(.7,1e4,1); %Random from Geometric
   %        [D PD]= allfitdist(data,'PDF','DISCRETE');
   %        PD{1}
   %
   %  EXAMPLE 4
   %     Compare the resulting distributions under two different assumptions
   %     of discrete data. The first, that it is known to be derived from a
   %     Binomial Distribution with known 'n'. The second, that it may be
   %     Binomial but 'n' is unknown and should be estimated. Note the second
   %     scenario may not yield a Binomial Distribution as the best fit, if
   %     'n' is estimated incorrectly. (Best to run example a couple times
   %     to see effect)
   %        data = binornd(10,.3,1e2,1);
   %        [D1 PD1] = allfitdist(data,'n',10,'DISCRETE','PDF'); %Force binomial
   %        [D2 PD2] = allfitdist(data,'DISCRETE','PDF');       %May be binomial
   %        PD1{1}, PD2{1}                             %Compare distributions
   %
   %    Mike Sheppard
   %    Last Modified: 17-Feb-2012

   
   % mgc: I started converting to parser but did not finish. It may not be
   % needed, instead just add them to the signature file. 
   % p = inputParser;
   % p.FunctionName = mfilename;
   % p.addRequired('X', @isnumeric);
   % p.addParameter('distname', defaultdists, @ischarlike);
   % p.addParameter('sortby', 'BIC', @ischarlike);
   % p.addParameter('normalization', 'PDF', @ischarlike);
   % p.addParameter('frequencies', nan, @isnumeric);
   % p.addParameter('isdescrete', false, @islogical);
   % p.parse(X, varargin{:});
   
   % function distname = defaultdists
   %    distname={'beta', 'birnbaumsaunders', 'exponential', ...
   %       'extreme value', 'gamma', 'generalized extreme value', ...
   %       'generalized pareto', 'inversegaussian', 'logistic', 'loglogistic', ...
   %       'lognormal', 'nakagami', 'normal', ...
   %       'rayleigh', 'rician', 'tlocationscale', 'weibull'};
   % end
   
   % Check Inputs
   if nargin == 0
      X = 10 .^ ((normrnd(2, 10, 1e4, 1)) / 10);
      sortby = 'BIC';
      varargin = {'CDF'};
   end
   if nargin == 1
      sortby = 'BIC';
   end
   
   sortbyname = {'NLogL','BIC','AIC','AICc'};
   if ~any(ismember(lower(sortby), lower(sortbyname)))
      oldvar = sortby; %May be 'PDF' or 'CDF' or other commands
      if isempty(varargin)
         varargin = {oldvar};
      else
         varargin = [oldvar varargin];
      end
      sortby = 'BIC';
   end
   if nargin < 2
      sortby='BIC';
   end

   distname = {'beta', 'birnbaumsaunders', 'exponential', ...
      'extreme value', 'gamma', 'generalized extreme value', ...
      'generalized pareto', 'inversegaussian', 'logistic', 'loglogistic', ...
      'lognormal', 'nakagami', 'normal', ...
      'rayleigh', 'rician', 'tlocationscale', 'weibull'};

   if ~any(strcmpi(sortby,sortbyname))
      error( ...
         'allfitdist:SortBy','Sorting must be either NLogL, BIC, AIC, or AICc');
   end

   % Input may be mixed of numeric and strings, find only strings
   args = varargin;
   strs = find(cellfun(@(vs) ischar(vs), args));
   args(strs) = lower(args(strs));

   % Next check to see if 'PDF' or 'CDF' is listed
   numplots = sum(ismember(args(strs), {'pdf' 'cdf'}));
   if numplots >= 2
      error('ALLFITDIST:PlotType', 'Either PDF or CDF must be given');
   end

   plotind = false; % plot indicator
   if numplots == 1
      plotind = true;
      indxpdf = ismember(args(strs), 'pdf');
      plotpdf = any(indxpdf);
      indxcdf = ismember(args(strs), 'cdf');

      args(strs(indxpdf | indxcdf)) = []; % Delete 'PDF' and 'CDF' in args
   end

   % Check to see if discrete
   strs = find(cellfun(@(vs) ischar(vs), args));
   indxdis = ismember(args(strs), 'discrete');
   discind = false;

   if any(indxdis)
      discind = true;
      distname = {'binomial', 'negative binomial', 'poisson'};
      args(strs(indxdis)) = []; % Delete 'DISCRETE' in args
   end

   strs = find(cellfun(@(vs) ischar(vs), args));

   N = numel(X); % Number of data points
   X = X(:);
   D = [];

   % Check for NaN's to delete
   dropnan = isnan(X);

   %Check to see if frequency is given
   indxf = ismember(args(strs), 'frequency');
   if any(indxf)
      f = args{1+strs((indxf))};
      f = f(:);
      if numel(f) ~= numel(X)
         error('ALLFITDIST:PlotType','Matrix dimensions must agree');
      end
      dropnan = dropnan | isnan(f);
      X(dropnan) = [];
      f(dropnan) = [];

      % Save back into args
      args{1+strs((indxf))} = f;
   else
      X(dropnan) = [];
   end

   % Run through all distributions in FITDIST function
   warning('off', 'all'); % Turn off all future warnings
   for indx=1:length(distname)
      try
         switch distname{indx}
            case 'binomial'
               PD = fitbinocase(X, args, strs); % Special case
            case 'generalized pareto'
               PD = fitgpcase(X, args, strs); % Special case
            otherwise
               % Built-in distribution using FITDIST
               PD = fitdist(X, distname{indx}, args{:});
         end

         NLL = PD.NLogL; % -Log(L)

         % If NLL is non-finite number, produce error to ignore distribution
         if ~isfinite(NLL)
            error('non-finite NLL');
         end

         num = length(D)+1;
         PDs(num) = {PD}; %#ok<*AGROW>
         k = numel(PD.Params); %Number of parameters
         D(num).DistName = PD.DistName;
         D(num).NLogL = NLL;
         D(num).BIC = -2*(-NLL)+k*log(N);
         D(num).AIC = -2*(-NLL)+2*k;
         D(num).AICc = (D(num).AIC)+((2*k*(k+1))/(N-k-1));
         D(num).ParamNames = PD.ParamNames;
         D(num).ParamDescription = PD.ParamDescription;
         D(num).Params = PD.Params;
         D(num).Paramci = PD.paramci;
         D(num).ParamCov = PD.ParamCov;
         D(num).Support = PD.Support;
      catch err %#ok<NASGU>
         %Ignore distribution
      end
   end
   warning('on','all'); %Turn back on warnings
   if numel(D)==0
      error('ALLFITDIST:NoDist','No distributions were found');
   end

   % Sort distributions   
   [~,indx1] = sort([D.(sortby)]);
   D = D(indx1); 
   PD = PDs(indx1);

   % Plot if requested
   if plotind
      h = plotfigs(X,D,PD,args,strs,plotpdf,discind);
   end
end

%%
function PD = fitbinocase(data, args, strs)
   % Special Case for Binomial
   
   % 'n' is estimated if not given
   binoargs = args;
   
   % Check to see if 'n' is given
   indxn = any(ismember(args(strs), 'n'));
   
   % Check to see if 'frequency' is given
   indxfreq = ismember(args(strs), 'frequency');
   
   if ~indxn
      % Use Method of Moment estimator
      % E[x] = np, V[x] = np(1-p) -> nhat=E/(1-(V/E));
      
      if isempty(indxfreq)||~any(indxfreq)
         %Raw data
         mnx=mean(data);
         nhat=round(mnx/(1-(var(data)/mnx)));
      else
         %Frequency data
         freq=args{1+strs(indxfreq)};
         m1=dot(data,freq)/sum(freq);
         m2=dot(data.^2,freq)/sum(freq);
         mnx=m1; vx=m2-(m1^2);
         nhat=round(mnx/(1-(vx/mnx)));
      end
      %If nhat is negative, use maximum value of data
      if nhat<=0, nhat=max(data(:)); end
      binoargs{end+1}='n'; binoargs{end+1}=nhat;
   end
   PD = fitdist(data,'binomial',binoargs{:});
end

%%
function PD = fitgpcase(data, args, strs)
   % Special Case for Generalized Pareto
   % 'theta' is estimated if not given
   gpargs = args;
   
   % Check to see if 'theta' is given
   indxtheta = any(ismember(args(strs), 'theta'));
   
   if ~indxtheta
      % Use minimum value for theta, minus small part
      thetahat = min(data(:)) - 1e-12;

      % mgc: use the mode trick. This works, but it fits the tail, and often
      % that is not what is wanted, so I turned it off.
      % thetahat = estimatemode(data(:));
      % data = data(data > thetahat);

      gpargs{end+1} = 'theta'; 
      gpargs{end+1} = thetahat;
   end
   PD = fitdist(data, 'GeneralizedPareto', gpargs{:});
end

%%
function H = plotfigs(X, D, PD, args, strs, plotpdf, discind)
   % Plot functionality for continuous case due to Jonathan Sullivan
   % Modified by author for discrete case

   % Maximum number of distributions to include
   % max_num_dist=Inf;  %All valid distributions
   max_num_dist = 4;

   %Check to see if frequency is given
   indxf = ismember(args(strs), 'frequency');
   if any(indxf)
      freq = args{1+strs((indxf))};
   end

   H.f = figure('Position',[1 1 1152 624]);

   % Probability Density / Mass Plot
   if plotpdf
      if ~discind
         % Continuous Data
         
         % Create a grid to evaluate the histogram
         nbins = max(min(ceil(sqrt(length(X))), 100), 30);
         edges = linspace(min(X), max(X), nbins);
         Fhist = histc(X, edges - mean(diff(edges)));
         Fhist = Fhist./sum(Fhist)./mean(diff(edges));
         inds = 1:min([max_num_dist, numel(PD)]);
         
         % Create a finer grid for the pdf fit
         xpdf = linspace(min(X), max(X), nbins*10)';
         
         % % mgc: a refactored version but I kept og for now
         % % Create bin edges with an extra edge to cover the range of data
         % nbins = max(min(ceil(sqrt(length(X))), 100), 30);
         % edges = linspace(min(X), max(X), nbins + 1);
         % centers = (edges(1:end-1) + edges(2:end)) / 2;
         % [Fhist, ~] = histcounts(X, edges, 'Normalization', 'pdf');

         % mgc: to plot GPD, censor the x values below theta
         Fpdf = nan(numel(xpdf), max_num_dist);
         for n = 1:max_num_dist
            thisPD = PD{inds(n)};
            Fpdf(:, n) = pdf(thisPD, xpdf);
            if strcmp(thisPD.DistributionName, 'Generalized Pareto')
               Fpdf(xpdf <= thisPD.theta, n) = nan;
            end
         end
         % mgc: this was the original method:
         % ys = cellfun(@(PD) pdf(PD,xi2), PD(inds),'UniformOutput',0);
         % ys = cat(2,ys{:});

         H.b = bar(edges, Fhist, 'FaceColor', [160 188 254]/255, 'EdgeColor', 'k');
         hold on;
         H.p1 = plot(xpdf, Fpdf, 'LineWidth', 1.5);

         % mgc if i wanted to also print the peak of the pdf, I could use
         % something like this, but I need to get the fit to all PD objects
         % then find the max value of the fit
         %xfit = min(data):0.01:max(data);
         %pfit = pdf();

         % mgc print expected value on figure
         mus = cellfun(@(PD) mean(PD),PD(inds),'UniformOutput',0);
         mes = cellfun(@(PD) median(PD),PD(inds),'UniformOutput',0);
         Dn = D(inds);
         ltxt{1} = 'empirical';
         for n = 1:numel(mus)
            ltxt{n+1} = [   'E(x)=' num2str(round(mus{n},2)) ...
               ', M(x)=' num2str(round(mes{n},2)) ...
               '  (' Dn(n).DistName ')'];
         end
         % mgc end

         legend(ltxt,'Location','NE','FontSize',12)
         xlabel('Value');
         ylabel('Probability Density');
         title('Probability Density Function');
         grid on
      else
         %Discrete Data
         xpdf = min(X):max(X);
         
         % To only show observed x-values:
         %xpdf = unique(x)'; 
         
         indxf = ismember(args(strs), 'frequency');
         if any(indxf)
            Fhist = zeros(size(xpdf));
            Fhist((ismember(xpdf, X))) = freq; 
            Fhist = Fhist' ./ sum(Fhist);
         else
            Fhist = histc(X,xpdf); 
            Fhist = Fhist ./ sum(Fhist);
         end
         
         inds = 1:min([max_num_dist, numel(PD)]);
         Fpdf = cellfun(@(PD) pdf(PD, xpdf), PD(inds), 'Uniform', false);
         Fpdf = cat(1, Fpdf{:})';
         
         H.b = bar(xpdf, [Fhist Fpdf]);
         legend(['empirical',{D(inds).DistName}],'Location','NE')
         xlabel('Value');
         ylabel('Probability Mass');
         title('Probability Mass Function');
         grid on
      end
      H.ax = gca;
   else

      % Cumulative Distribution
      if ~discind
         
         % Continuous Data
         [Fhist,edges] = ecdf(X);
         inds = 1:min([max_num_dist, numel(PD)]);
         Fpdf = cellfun(@(PD) cdf(PD, edges), PD(inds), 'Uniform', false);
         Fpdf = cat(2, Fpdf{:});
         
         if max(edges)/min(edges) > 1e4
            lgx = true; 
         else
            lgx = false; 
         end
         
         H.s1 = subplot(2,1,1);
         if lgx
            H.p2 = semilogx(edges, Fhist, 'k', edges, Fpdf);
         else
            H.p2 = plot(edges, Fhist, 'k', edges, Fpdf);
         end
         
         legend(['empirical',{D(inds).DistName}],'Location','NE')
         xlabel('Value');
         ylabel('Cumulative Probability');
         title('Cumulative Distribution Function');
         grid on
         
         H.s2 = subplot(2,1,2);
         y = 1.1 * bsxfun(@minus, Fpdf, Fhist);
         if lgx
            H.p3 = semilogx(edges, bsxfun(@minus, Fpdf, Fhist));
         else
            H.p3 = plot(edges, bsxfun(@minus, Fpdf, Fhist));
         end
         ybnds = max(abs(y(:)));
         ax = axis;
         axis([ax(1:2) -ybnds ybnds]);
         legend({D(inds).DistName},'Location','NE')
         xlabel('Value');
         ylabel('Error');
         title('CDF Error');
         grid on
         
      else
         % Discrete Data
         indxf = ismember(args(strs), 'frequency');
         
         if any(indxf)
            [Fhist, edges] = ecdf(X, 'frequency', freq);
         else
            [Fhist, edges] = ecdf(X);
         end
         
         % Check unique xi, combine fi
         [edges, ign, indx] = unique(edges); %#ok<ASGLU>
         
         Fhist = accumarray(indx, Fhist);
         inds = 1:min([max_num_dist, numel(PD)]);
         
         Fpdf = cellfun(@(PD) cdf(PD, edges), PD(inds), 'Uniform', false);
         Fpdf = cat(2, Fpdf{:});
         
         H.s1 = subplot(2,1,1);
         H.p2 = stairs(edges, [Fhist Fpdf]);
         
         legend(['empirical', {D(inds).DistName}], 'Location', 'NE')
         xlabel('Value');
         ylabel('Cumulative Probability');
         title('Cumulative Distribution Function');
         grid on
         
         H.s2 = subplot(2,1,2);
         y = 1.1 * bsxfun(@minus, Fpdf, Fhist);
         H.p2 = stairs(edges, bsxfun(@minus, Fpdf, Fhist));
         
         ybnds = max(abs(y(:)));
         ax = axis;
         axis([ax(1:2) -ybnds ybnds]);
         legend({D(inds).DistName},'Location','NE')
         xlabel('Value');
         ylabel('Error');
         title('CDF Error');
         grid on
      end
      H.ax = gca;
   end
end