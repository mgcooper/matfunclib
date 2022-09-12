function [delF] = L1grad(m1p,m2p,xp,M1,M2,SM1,SM2,xo,yo,sx,sy,a,b,xbar,ybar)

%******************************
%
% gradient solver routine
%
%******************************

% RAS 8/01

% input variables:
%
% m2p=predicted line slope, transformed coordinates
% m1p=predicted line intercept, transformed coordinates
% xp=predicted x values, transformed coordinates
% ...all above from last iteration
% nrm=power of vector norm
% M1=prior intercept
% M2=prior slope
% SM1=intercept std. dev.
% SM2=slope std. dev.
% xo=prior x values, transformed coordinates
% yo=prior y values, transformed coordinates
% sx=std. dev. x values, transformed coordinates
% sy=std. dev. y values, transformed coordinates
% a=scalar for x transform
% b=scalar for y transform
% xbar=mean x data, orig. coordinates
% ybar=mean y data, orig. coordinates
%
% output variables:
%
% delF=gradient matrix, N+2 x N+2 where N is # of data pairs
%

N=length(xo);	% # of observations
delF=zeros(N+2,N+2);

M1p=b*m1p-b*m2p*xbar/a+ybar;	% transform present value to orig. coords
M2p=b*m2p/a;

% partial derivatives...

m1pgrad=b*sign(M1p-M1)/SM1;
m2pgrad=(b/a)*sign(M2p-M2)/SM2;

xe=zeros(size(xo));
ye=zeros(size(xo));


xe=sign(xp-xo)./sx;
ye=sign(m2p*xp-yo+m1p)./sy;
xd=xe+m2p*ye;	% dF/dx

delF(1:N,1:N)=diag(xd);
delF(1:N,N+1)=ye;	% df/dm1
delF(N+1,N+1)=m1pgrad;
delF(1:N,N+2)=xp.*ye;	% df/dm2
delF(N+2,N+2)=m2pgrad;
delF(N+1,N+2)=-m1pgrad*xbar/a;
