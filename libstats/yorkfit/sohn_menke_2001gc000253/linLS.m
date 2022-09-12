function [mest,mvar,Yhat] = linLS(data,xi,yi)
%
% *****************************************
%
% linear least squares estimation of a straight line to xy data pairs
%
% RAS 7/00
%
% *****************************************
%
%
% data is a 4 column matrix of data pairs and standard deviations
% data pairs are in columns 1 and 2, with x values in column xi,
% and y values in column yi
%
% standard deviations, or weights, are in columns 3 and 4, with
% x weights in xi+2, and y weights in yi+2
%
% unity weighting is used if columns 3 and 4 are zeros
%
%
% slope and intercept estimates contained in mest
% mest(1)=intercept, mest(2)=slope
% mvar contains corresponding posterior variance estimates (diagonal
% elements of posterior covariance matrix


% check to see what weights should be used in linear inverse
% if variance of both x and y is zero, use weights of one

[N,col]=size(data);

if data(:,yi+2)==zeros(N,1)
    W=diag(ones(N,1),0);
else
    W=diag(1./data(:,yi+2),0);
    W=W.^2;             % go from std dev to variance for weighting
end
G=zeros(N,2);
d=zeros(N,1);
Yhat=zeros(N,1);
d=data(:,yi);
G(:,1)=ones(N,1);
G(:,2)=data(:,xi);
GtG=zeros(2,2);
Gtd=zeros(2,1);
mest=zeros(2,1);
mvar=zeros(2,1);
covLS=zeros(2,2);
GtG=G'*W*G;
Gtd=G'*W*d;
mest=GtG\Gtd;
covLS=inv(GtG);
mvar=diag(covLS);
Yhat=G*mest;
