function [F] = L1(xo,yo,sx,sy,M1,M2,SM1,SM2,m1p,m2p,xp,a,b,xbar,ybar)

%**************************
%
% objective function for L1 norm
%
%**************************
%
% RAS 5/01
%

% input variables are:
%
% xo=observed x values
% yo=observed y values
% sx=std dev of x values
% sy=std dev of y values
% M2=initial slope estimate
% M1=initial intercept estimate
% SM2=std dev of slope estimate
% SM1=std dev of intercept estimate
% m2p=predicted estimate of slope
% m1p=predicted estimate of intercept
% xp=predicted x-values of data
% a=scalar for x value transform
% b=scalar for y value transform
%
% output is the vector F, containing L1 misfit for each parameter
% norm

xte=0;
yte=0;	% x and y sum error variables

M1p=b*m1p-b*m2p*xbar/a+ybar;
M2p=b*m2p/a;

M1e=abs(M1p-M1)/SM1;	% individual misfits
M2e=abs(M2p-M2)/SM2;
xe=abs(xp-xo)./sx;
ye=abs(m2p*xp-yo+m1p)./sy;
xte=sum(xe);
yte=sum(ye);
xe=xe+ye;	% y parameter not explicit in model

[N,col]=size(xp);
F=zeros(N+1,1);
F=[xe;M1e;M2e];
%F=M1e+M2e+xte+yte;
