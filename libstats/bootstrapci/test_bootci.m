
% this was copied out of bfra_fitphidist. it cleared up some confusion
% about confidence intervals. First, my function tconf is designed to
% compute SE and CI on a sample population using a supplied mean and
% standard devaiation, sample size, and alpha, e..g if i already fit a
% distribution, whereas my function stderr is non-parametric, it computes
% the eman and standar deviation of a sample, so it assumes normality (so
% deos tconf). in contrast, if I use bootstrap, i can get a population of
% mean values and a population of standard dev's, or any other value by
% passing in a function. with the population of mean values, i can then
% compute a standard error and ci on the MEAN, which is different than the
% standard error and CI on the sample itself. 

% parametric standard error / CI's
   [SE,CI,PM]  = tconf(PD.mean,PD.std,numel(phi)-1,0.05);
   
   % sample standard error / CI's
   [SE,CI,PM] = stderr(phi);
   
   % bootstrap standard error / CI's 
   N  = 1000;
   if bootstrap == true
      reps     = bootstrp(N,@betafit,phi);
      mureps   = reps(:,1)./(sum(reps,2));
      sigreps  = prod(reps,2)./((sum(reps,2)+1).*(sum(reps,2)).^2);
   end
   muav  = mean(mureps);               % estimate of the sample mean
   mupm  = std(mureps)*1.96;           % estimate of the sample CI
   mupm  = mean(sqrt(sigreps))*1.96;   % estimate of the sample CI
   
%    % this cleared up some confusion - from bootstrap sample, can get the
%    % mean and the ci on the mean, but the ci on the mean is not what we 
%    % want, we want the ci on the sample i.e. the mean +/- 2 std dev's
%    muav  = mean(mureps);         % estimate of the sample mean
%    muse  = std(mureps)/sqrt(N);  % standard error on the mean
%    mupm  = muse*1.96;            % conf int on the mean
%    sigav = mean(sqrt(sigreps));  % estimate of the sample standard deviation
%    sigpm = sigav*1.96;
%    
%    % this would repeat the approach above - estimate of std dev and the ci 
%    sigse = std(sigreps)/sqrt(N); % standard error on the mean
%    sigpm = sigse*1.96
   