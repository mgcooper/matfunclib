function [h,fit,S,l] = plotLinRegBounded( x,y,varargin)

% NOTE: much of my older code used an older version of this function that
% did not add conf intervals and did not automatically print the legend. I
% modified this code to make the distance vs depth plots for the weatheirng
% crust paper. I should have renamed this a new function and kept the old.
% I should do this at a later date, because it is not always desirable to
% plot the conf. int's or the legend. 

%MYLINREG linear regression, with intercept, limited functionality
%   Detailed explanation goes here
    
    xnaninds    =   find(isnan(x));
    ynaninds    =   find(isnan(y));
    naninds     =   unique([xnaninds;ynaninds]);
    
    x(naninds)  =   [];
    y(naninds)  =   [];
    
    [p,S]           =   polyfit(x,y,1);
    yfit            =   polyval(p,x);
    
    fit.resid       =    y - yfit;
    
    %Square the residuals and total them obtain the residual sum of squares:
    
    fit.SSresid     =    sum(fit.resid.^2);
    
    %Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:
    
    fit.SStotal     =    (length(y)-1) * var(y);
    
    %Compute R2 using the formula given in the introduction of this topic:
    
    fit.rsq         =   1 - fit.SSresid/fit.SStotal;
    fit.slope       =   p(1);
    fit.intercept   =   p(2);    

    % resort to built in function for p value
    lm              =   fitlm(x,y);
    
    fit.pval        =   lm.Coefficients.pValue(2);
    
    % this fits to the data on screen
%     h               =   plot(x,yfit,varargin{:});

    % this fits to the whole axis
%     xdata           =   get(gca,'XLim');
%     xdata           =   linspace(xdata(1),xdata(2),50);
%     ydata           =   fit.slope .* xdata + fit.intercept;
    
    % Extent of the data.
    mx              =   min(x);
    Mx              =   max(x);
    my              =   min(y);
    My              =   max(y);

    % Scale factors for plotting. NOTE: These worked for the weathering
    % crust transect data but don't always work elsewhere, may want to
    % remove and force axes to be equal
    sx              =   0.05*(Mx-mx);
    sy              =   0.05*(My-my);
    
    % build x fit vector and predict y at high sampling res
    xfit            =   mx-sx:0.01:Mx+sx;
    yfit            =   polyval(p,xfit);
    
    % get confidence intervals
%     [Y,DELTA]       =   polyconf(p,xfit,S,'predopt','curve');
    xsort           =   sort(lm.Variables.x1);  % observed x
    [ypred,yci]     =   predict(lm,xsort);      % predicted y, y conf int.    
    yciL            =   yci(:,1);               % lower conf. int.
    yciH            =   yci(:,2);               % upper conf. int.
    DELTA           =   yciH-ypred;             % delta for bounded line
    
    % plot the data, fit, and conf intvls
    [h(1),h(2)]     =   boundedline(xsort,ypred,DELTA);hold on;
                        
    h(3)            =   scatter(x,y,45, ...
                                'MarkerEdgeColor',[0 .5 .5],...
                                'MarkerFaceColor',[0 .7 .7],...
                                'LineWidth',1);
    
    % add two dummy plots for the r2 and p value in legend
    h(4)            =   plot(xfit(1),yfit(1),'color','none');

    % get the p value to determine the requisite precision
    pval            =   fit.pval;
    prec            =   ceil(log10(pval));
    
    % Add the legend
    ltext           =   {'Observations'                                 , ...
                        ['Fit = ' printf(p(1),3) 'x + ' printf(p(2),1)] , ...
                        '95% Prediction Intervals'                      , ...
                        ['r2 = ' printf(fit.rsq,2)                      , ...
                            ', p<10^{' printf(prec,0) '}']};
                    
    l               =   legend([h(3) h(1) h(2) h(4)], ltext);

    % put the legend in the upper left (right) if positive (negative) slope
    if fit.slope > 0
        l.Location  = 'Northwest';
    elseif fit.slope < 0
        l.Location  = 'Northeast';
    else
        l.Location  = 'Best';
    end
    
    set(gca,'TickDir','out');
end

