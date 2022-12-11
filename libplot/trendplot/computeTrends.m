function [ab,err,yfit,yci] = computeTrends(t,y,method,alpha,qtl)


% direct copy out of trendplot on 5 dec 2022 so I can send timetabletrends here


inan  = isnan(y);
ncol  = size(y,2);
ab    = nan(ncol,2);
err   = nan(ncol,1);
ci    = nan;
yci   = nan(size(y,1),2); % confidence bounds for trendline

% note, conf int's not symmetric for quantile regression, so I use the
% mean of the lower and upper for now 

% compute trends
for n = 1:ncol
   if isnan(qtl)
      switch method
         case 'ts'
            % need to eventually merge tsregr and ktaub, the latter
            % doesn't return the intercept and the former doesn't return
            % conf levels or much other detail.

            % only get conf levels if requested
            if isnan(alpha)
               ab(n,:)  = tsregr(t,y(:,n));
            else
               ab(n,:)  = tsregr(t,y(:,n));
               out      = ktaub([t,y(:,n)], alpha, false);
               ci       = [out.CIlower, out.CIupper];
               err(n)   = mean([ab(n,2)-ci(1),ci(2)-ab(n,2)]);
            end

            % not sure we want the setnan
            yfit  = ab(:,1) + ab(:,2)*t'; yfit = yfit';
            yfit  = setnan(yfit,[],inan);

         case 'ols'

            if isnan(alpha)
               ab(n,:)  = olsfit(t,y(:,n));
            else

               mdl      = fitlm(t,y(:,n));
               B        = mdl.Coefficients.Estimate;  % Coefficients
               ci       = coefCI(mdl,alpha);          % coefficent CIs
               ab(n,:)  = B;
               err(n)   = ci(2,2)-ab(n,2);            % symmetric for ols
               [yfit,yci] = predict(mdl,t,'alpha',alpha); % fitted line and CIs

               % [B,CI] = regress(y(:,n),[ones(size(t)) t],alpha);
               % CB(:,1)= CI(1,1)+CI(2,1)*t;
               % CB(:,2)= CI(1,2)+CI(2,2)*t;
               % CB     = anomaly(CB);          % convert to anomalies?

            end
      end
   else
      % only get conf levels if requested
      if isnan(alpha)
         ab(n,:)     = quantreg(t,y(:,n),qtl);
      else
         [ab(n,:),S] = quantreg(t,y(:,n),qtl,1,1000,alpha);
         ci          = S.ci_boot';
         err(n)      = mean([ab(n,2)-ci(2,1),ci(2,2)-ab(n,2)]);
      end

      yfit = ab(:,1) + ab(:,2)*t'; yfit = yfit';
      yfit = setnan(yfit,[],inan);

   end
end