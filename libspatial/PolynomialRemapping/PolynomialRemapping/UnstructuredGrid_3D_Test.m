%% Unstructured Grid
% This examples shows how to use ConstructProjector3D on unstructured
% grids. Two sets of points are generated randomly. 
clear;clc;close all
%% Initializing Part I
disp('- Initializing')
rSource=2*pi;
rDestination=rSource*1.05; % This slightly bigger radius causes some points
                           % on destination grid being outside of the
                           % source grid; hence, on those points it is
                           % actually extrapolation and not interpolation.

ns=1600;
nd=500;

nPoly=3; % We gonna fit a 3rd order polynomial, 
nInterp=-70;

%% Generating the Source grid
disp('- Generating the Source grid')
xs=rand(ns,1)*2*rSource-rSource;
ys=rand(ns,1)*2*rSource-rSource;
zs=rand(ns,1)*2*rSource-rSource;

%% Generating the Destination Grid
disp('- Generating the Destination Grid')
xd=rand(nd,1)*2*rDestination-rDestination;
yd=rand(nd,1)*2*rDestination-rDestination;
zd=rand(nd,1)*2*rDestination-rDestination;

%% Ploting source and destination grid
figure
plot3(xs,ys,zs,'k.','MarkerSize',20);
hold on
plot3(xd,yd,zd,'kx','MarkerSize',20);
axis tight
axis square
legend('Source Grid','Destination Grid','Location','North')
title('Distribution of the points')
grid on

%% Generating the interpolant
disp('- Generating the interpolant')
P=ConstructPolyInterpolant3D(xs,ys,zs,xd,yd,zd,nPoly,nInterp);

%% Generating sum data
disp('- Generating sum data and interpolating')
F1=@(x,y,z) (sin(sqrt(x.^2+y.^2+z.^2)));
F2=@(x,y,z) (sqrt(x.^2+y.^2+z.^2));
F3=@(x,y,z) (exp(-sqrt(x.^2+y.^2+z.^2)));
F4=@(x,y,z,x0,y0,z0) (exp(-sqrt((x-x0).^2+(y-y0).^2+(z-z0).^2)));

V=zeros(ns,4);
V(:,1)=F1(xs,ys,zs);
V(:,2)=F2(xs,ys,zs);
V(:,3)=F3(xs,ys,zs);
V(:,4)=F4(xs,ys,zs,0,0,0);

V_Analytic=zeros(nd,4);
V_Analytic(:,1)=F1(xd,yd,zd);
V_Analytic(:,2)=F2(xd,yd,zd);
V_Analytic(:,3)=F3(xd,yd,zd);
V_Analytic(:,4)=F4(xd,yd,zd,0,0,0);

% Interpolating
V_interp=P*V;

% Note that since the points are randomly generated the RMSE would change
% each time. Depending on how the points are distributed you may get very
% good or very bad RMSE.
RMSE=sqrt(mean( (V_interp-V_Analytic).^2 ));

%% plotting
figure
for i=1:4
  subplot(2,2,i)
  plot(V_interp(:,i),'k.','MarkerSize',20);
  hold on
  plot(V_Analytic(:,i),'kx','MarkerSize',20);
  legend('Interpolated','Analytic');
  title(['RMSE= ' num2str(RMSE(i))]);
end