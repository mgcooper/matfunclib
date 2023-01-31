function [fit,S ] = myLinReg( x,y )
%MYLINREG linear regression, with intercept, limited functionality
% 
%   [fit,S ] = myLinReg( x,y )
% 
% See also: myfit

% xnaninds = find(isnan(x));
% ynaninds = find(isnan(y));
% naninds = unique([xnaninds;ynaninds]);
% x(naninds) = [];
% y(naninds) = [];

% mgc added this instead of up above, but only works with the toolbox
[x,y] = prepareCurveData(x,y);

% build the model
[p,S] = polyfit(x,y,1);
yfit = polyval(p,x);

% get the model residuals
fit.resid = y - yfit;

%Square the residuals and total them obtain the residual sum of squares:
fit.SSresid = sum(fit.resid.^2);

%Compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1:
fit.SStotal = (length(y)-1) * var(y);

%Compute R2 using the formula given in the introduction of this topic:
fit.rsq = 1 - fit.SSresid/fit.SStotal;
fit.slope = p(1);
fit.intercept = p(2);
