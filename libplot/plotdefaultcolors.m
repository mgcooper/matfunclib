function plotdefaultcolors()
   %plotdefaultcolors Plot default matlab colors

   % load('defaultcolors.mat','dc'); c = dc;
   % load('distinguishablecolors.mat','dc');

   c = defaultcolors();
   dc = distinguishable_colors(8);


   x   = 1:10;
   y   = x;

   figure; hold on;
   plot(x,y,'LineWidth',4,'Color',dc(1,:));
   plot(x,0.9.*y,'LineWidth',4,'Color',dc(2,:));
   plot(x,0.8.*y,'LineWidth',4,'Color',dc(3,:));
   plot(x,0.7.*y,'LineWidth',4,'Color',dc(4,:));
   plot(x,0.6.*y,'LineWidth',4,'Color',dc(5,:));
   plot(x,0.5.*y,'LineWidth',4,'Color',dc(6,:));
   plot(x,0.4.*y,'LineWidth',4,'Color',dc(7,:));
   plot(x,0.3.*y,'LineWidth',4,'Color',dc(8,:));
   legend('1','2','3','4','5','6','7','8','Location','best')
   title('distinguishable colors');

   figure; hold on;
   plot(x,y,'LineWidth',4,'Color',c(1,:));
   plot(x,0.9.*y,'LineWidth',4,'Color',c(2,:));
   plot(x,0.8.*y,'LineWidth',4,'Color',c(3,:));
   plot(x,0.7.*y,'LineWidth',4,'Color',c(4,:));
   plot(x,0.6.*y,'LineWidth',4,'Color',c(5,:));
   plot(x,0.5.*y,'LineWidth',4,'Color',c(6,:));
   plot(x,0.4.*y,'LineWidth',4,'Color',c(7,:));
   plot(x,0.3.*y,'LineWidth',4,'Color',c(8,:));
   legend('1','2','3','4','5','6','7','8','Location','best')
   title('default colors');

   figure; hold on;
   plot(x,y,'LineWidth',4,'Color',c(1,:));
   plot(x,0.9.*y,'LineWidth',4,'Color',c(2,:));
   plot(x,0.8.*y,'LineWidth',4,'Color',c(3,:));
   plot(x,0.7.*y,'LineWidth',4,'Color',c(4,:));
   plot(x,0.6.*y,'LineWidth',4,'Color',c(5,:));
   plot(x,0.5.*y,'LineWidth',4,'Color',c(6,:));
   plot(x,0.4.*y,'LineWidth',4,'Color',c(7,:));
   plot(x,0.3.*y,'LineWidth',4,'Color',c(8,:));
   plot(x,0.2.*y,'LineWidth',4,'Color',c(9,:));
   plot(x,0.1.*y,'LineWidth',4,'Color',c(10,:));
   plot(x,0.05.*y,'LineWidth',4,'Color',c(11,:));
   plot(x,0.01.*y,'LineWidth',4,'Color',c(12,:));
   legend('1','2','3','4','5','6','7','8','9', '10', '11', '12','Location','best')
   title('default colors - extended');

end
