function [ lagcorr ] = myautocorr( X, lag, dim )
%AUTOCORR computes autocorrelation of vector for lag along dimension dim
%   Detailed explanation goes here

numsamples  =   size(X,dim) - lag;

Xbar        =   mean(X,dim);
Xvar        =   var(X,numsamples,dim);

dif         =   X - Xbar;
dif1        =   dif(1:end-lag);
dif2        =   dif(lag+1:end);

difprod     =   dif1.*dif2;
difprodsum  =   sum(difprod,dim);
C           =   difprodsum/numsamples;

lagcorr     =   C/Xvar;

end

