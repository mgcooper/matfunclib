function [h,fit,S,l] = plotLinRegLine( x,y,pad,varargin)

% NOTE: much of my older code used an older version of this function that
% did not add conf intervals and did not automatically print the legend. I
% modified this code to make the distance vs depth plots for the weatheirng
% crust paper. I should have renamed this a new function and kept the old.
% I should do this at a later date, because it is not always desirable to
% plot the conf. int's or the legend. 

%MYLINREG linear regression, with intercept, limited functionality
%   Detailed explanation goes here

    if nargin == 2
        pad     = 2;
    end
    
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
    sx              =   pad/100*(Mx-mx);
    sy              =   pad/100*(My-my);
    
    % build x fit vector and predict y at high sampling res
    xfit            =   mx-sx:0.01:Mx+sx;
    yfit            =   polyval(p,xfit);
    
    % plot the data, fit, and conf intvls
    h               =   plot(xfit,yfit,'LineWidth',2,'LineStyle','--',varargin{:});
    
    % get confidence intervals and add to plot
    [Y,DELTA]       =   polyconf(p,xfit,S,'predopt','curve');
    
    % put the data in a structure
    fit.xfit        =   xfit;
    fit.yfit        =   yfit;
    fit.yupper      =   Y+DELTA;
    fit.ylower      =   Y-DELTA;
    
    box off
    set(gca,'TickDir','out');
end

