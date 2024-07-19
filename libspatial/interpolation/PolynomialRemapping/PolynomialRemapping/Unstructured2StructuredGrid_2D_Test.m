%% Unstructured Grid
% This examples shows how to use ConstructProjector2D to interpolate from
% and unstructured/Scattered grid onto a structured grid.
clear;clc; close all
%% Initializing Part I
disp('- Initializing')
rSource=pi;

ns=2000;

xMin=0;
xMax=2*pi;
yMin=0;
yMax=2*pi;

nx=40;
ny=40;

nPoly=4; % We gonna fit a fourth order polynomial, 
         % i.e. sum_{n,m=0}^{n,m=nPoly} x^n*y^m 
nInterp=-35; % nPoly=4 requires 25 points. However, 
             % we are going to use 35 points. This would be 
             % the least-square fit of the surface.
             % Note that: min(nInterp)=(nPoly+1)^2. Otherwise it won't work.
%% Generating the Source grid
disp('- Generating the Source grid')
xs=rand(ns,1)*2*rSource;
ys=rand(ns,1)*2*rSource;

%% Generating the destination grid - Finding the cell centers
disp('- Generating the destination grid')
[xn,yn]=meshgrid(linspace(xMin,xMax,nx),linspace(yMin,yMax,ny));
xc=(xn(1:ny-1,1:nx-1)+xn(2:ny,1:nx-1)+xn(1:ny-1,2:nx)+xn(2:ny,2:nx))*0.25;
yc=(yn(1:ny-1,1:nx-1)+yn(2:ny,1:nx-1)+yn(1:ny-1,2:nx)+yn(2:ny,2:nx))*0.25;

%% Ploting source and destination grid
figure
plot(xs(:),ys(:),'k.','MarkerSize',15);
hold on
plot(xc(:),yc(:),'kx','MarkerSize',15);
axis tight;
axis square;
legend('Source Grid','Destination Grid');

%% Constructing the Interpolant
% Note that we do not need the data on the source grid to create the
% interpolant.
disp('- Constructing the interpolant')
P=ConstructPolyInterpolant2D(xs,ys,xc,yc,nPoly,nInterp);

%% Generarting some Data
disp('- Generating some data and interpolating')
F1=@(x,y) (sin(sqrt(x.^2+y.^2)));
zs=F1(xs,ys);
zc_interp=reshape(P*zs(:),size(xc));
zc_Analytic=F1(xc,yc);
RMSE=sqrt(mean((zc_Analytic(:)-zc_interp(:)).^2));

figure
surface(xc,yc,zc_interp,'EdgeColor','none');
title(['nPoly: ' num2str(nPoly) ', RMSE= ' num2str(RMSE)]);
axis tight

%% Generating some more data
disp('- Generating multiple data field on the source grid and interpolating them.')
F2=@(x,y) (sin(x).*cos(y));
F3=@(x,y) (exp(-sqrt(x.^2+y.^2)));
F4=@(x,y,x0,y0) (exp(-sqrt((x-x0).^2+(y-y0).^2)));

zs(:,:,1)=F1(xs,ys);
zs(:,:,2)=F2(xs,ys);
zs(:,:,3)=F3(xs,ys);
zs(:,:,4)=F4(xs,ys,mean(xs(:)),mean(ys(:)));

zc_Analytic(:,:,1)=F1(xc,yc);
zc_Analytic(:,:,2)=F2(xc,yc);
zc_Analytic(:,:,3)=F3(xc,yc);
zc_Analytic(:,:,4)=F4(xc,yc,mean(xs(:)),mean(ys(:)));

%% Now interpolating
% Note that the same interpolant is used for all data fields and they can
% be all interpolated with one sparse matrix multiplication.
zc_interp=P*reshape(zs,ns,4); % There are 4 data fields each having nx*ny data points.
zc_interp=reshape(zc_interp,(nx-1),(ny-1),4); % these two commands can be combined in one.
                                              % They were separated for clarity.

%% calculating the RMSE and plotting
RMSE=zeros(4,1);
figure
for i=1:4
  RMSE(i)=sqrt(mean((reshape(zc_Analytic(:,:,i),(nx-1)*(ny-1),1)-reshape(zc_interp(:,:,i),(nx-1)*(ny-1),1)).^2));
  subplot(2,2,i);
  surface(xc,yc,squeeze(zc_interp(:,:,i)),'EdgeColor','none');
  title(['F' num2str(i) ', nPoly: ' num2str(nPoly) ', RMSE:' num2str(RMSE(i))])
  axis tight
  axis square
end