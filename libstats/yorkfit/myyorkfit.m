function [a,b,sig_a,sig_b,a_ci,b_ci,b_save] = myyorkfit(X,Y,sigX,sigY,alph,r)
% [a, b, sigma_a, sigma_b, b_save] = york_fit(X,Y,sig_X,sig_Y, r)
% Performs linear regression for data with errors in both X and Y, following
% the method in York et al.
% X,Y are row vectors of regression data.
% sigX and sigY are row vectors or single values for the error in X and Y.
% r is a row vector or single value for the correlation coefficeients
% between the errors.
% mgc: alph is the confidence level for intervals on the slope and intercept
%
%References:
%D. York, N. Evensen, M. Martinez, J. Delgado "Unified equations for the
%slope, intercept, and standard errors of the best straight line" Am. J.
%Phys. 72 (3) March 2004.

%Copyright Travis Wiens 2010 travis.mlfx@nutaksas.com

% updated mgc to add confidence intervals
% stats.t_c    = tinv(1-alpha/2,n-2);
% stats.b_ci   = b*[1 1] + stats.t_c*stats.s_b*[-1 1];

N_itermax       =   10;%maximum number of interations
tol             =   1e-15;%relative tolerance to stop at
N               =   numel(X);
if nargin<6
    r           =   0;
end
if numel(sigX)==1
    sigX       =   sigX * ones(1,N);
end
if numel(sigY)==1
    sigY       =   sigY * ones(1,N);
end
if numel(r)==1
    r           =   r * ones(1,N);
end
%make initial guess at b using linear squares
tmp             =   Y / [X; ones(1,N)];
b_lse           =   tmp(1);
%a_lse=tmp(2);

b               =   b_lse;          %initial guess
omega_X         =   1 ./ sigX.^2;
omega_Y         =   1 ./ sigY.^2;
alpha           =   sqrt(omega_X .* omega_Y);
b_save          =   zeros(1,N_itermax+1);%vector to save b iterations in
b_save(1)       =   b;

for i=1:N_itermax
    W       =   omega_X .* omega_Y ./ (omega_X + b^2*omega_Y - 2*b*r.*alpha);
    X_bar   =   sum(W.*X) / sum(W);
    Y_bar   =   sum(W.*Y) / sum(W);
    U       =   X - X_bar;
    V       =   Y - Y_bar;
    beta    =   W .* (U./omega_Y + b*V./omega_X - (b*U+V).*r./alpha);
    b       =   sum(W.*beta.*V) / sum(W.*beta.*U);
    b_save(i+1)=b;
    if abs((b_save(i+1)-b_save(i))/b_save(i+1))<tol
        break
    end
end
a           =   Y_bar - b*X_bar;
x           =   X_bar + beta;           % mgc step8, adjusted values
%y=Y_bar+b*beta;
x_bar       =   sum(W.*x) / sum(W);
%y_bar=sum(W.*y)/sum(W);
u           =   x - x_bar;
%v=y-y_bar;
sig_b       =   sqrt(1/sum(W.*u.^2));
sig_a       =   sqrt(1./sum(W)+x_bar^2*sig_b^2);
% mgc add confidence intervals
t_c         = tinv(1-alph/2,N-2);
a_ci        = a+t_c*sig_a*[-1 1];
b_ci        = b+t_c*sig_b*[-1 1];

% % mgc add correct form of standard error given in Cantrell
% beta_bar    = sum(W.*beta)/sum(W);
% beta_diffs  = beta-beta_bar;
% sigg_b      = sqrt(1/(sum(W.*beta_diffs.*beta_diffs)));
% xbarbetabar = x_bar+beta_bar;
% sigg_a      = sqrt(1/sum(W)+xbarbetabar*xbarbetabar*sigg_b*sigg_b);
% S           = sum((Y-(b.*X+a)).^2);
% sig_b       = sigg_b*sqrt(S/(N-2));
% sig_a       = sigg_a*sqrt(S/(N-2));
% 
% % mgc add confidence intervals
% t_c         = tinv(1-alph/2,N-2);
% a_ci        = a+t_c*sig_a*[-1 1];
% b_ci        = b+t_c*sig_b*[-1 1];

% figure;
% plot(z,b.*X+a); hold on;
% scatter(z,Y)
% 
% e = sum(120*(Y-(b.*X+a)).^2)
% 1/e


