function [r,mz,SZZ] = rxy(data,xi,yi)
%
% ****************************
% linear correlation function
%
% RAS 7/00
%
% ****************************
%
%
% calculates a weighted linear correlation function (rxy) from a set
% of x-y data pairs.
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

[N,col]=size(data);

if col ~= 4
    error('Must have 4 columns of data');
end
if xi <1 || xi > 2
    error('Invalid x-index passed');
end
if yi <1 || yi > 2
    error('Invalid y-index passed');
end
if yi==xi
    error('X and Y indices are equal');
end

clear my mz cbot ctop wx wy
cty=zeros(N,1);
ctz=zeros(N,1);
cty2=zeros(N,1);
ctz2=zeros(N,1);
ctzy=zeros(N,1);
if data(:,3)==zeros(N,1)
    data(:,3)=ones(N,1);
end
if data(:,4)==zeros(N,1)
    data(:,4)=ones(N,1);
end
wx=data(:,xi+2);
wx=1./wx;
wy=data(:,yi+2);
wy=1./wy;
mz=(sum(data(:,xi).*wx.^2))/sum(wx.^2);
my=(sum(data(:,yi).*wy.^2))/sum(wy.^2);
cty=wy.*(data(:,yi)-my);
ctz=wx.*(data(:,xi)-mz);
ctzy=cty.*ctz;
ctop=sum(ctzy);
cty2=cty.^2;
ctz2=ctz.^2;
SZZ=sum(ctz2);
cbot=sqrt(sum(cty2)*sum(ctz2));
r=ctop/cbot;
