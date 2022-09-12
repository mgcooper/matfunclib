clean

% try to break abline.

load('defaultcolors','c');

x       = 1:10;
y1      = 20 + 5.*x + 10.*rand(1,10);
y2      = 30 + 5.*x + 10.*rand(1,10);
y3      = 40 + 5.*x + 10.*rand(1,10);
y4      = 50 + 5.*x + 10.*rand(1,10);

ab1     = olsfit(x,y1);
ab2     = olsfit(x,y2);
ab3     = olsfit(x,y3);
ab4     = olsfit(x,y4);

% figure; 
% scatter(x,y1); hold on;
% scatter(x,y2);
% scatter(x,y3);
% scatter(x,y4);
% abline
% 
% figure; 
% scatter(x,y1,'filled'); hold on;
% scatter(x,y2,'filled');
% scatter(x,y3,'filled');
% scatter(x,y4,'filled');
% abline
% 
% % use different color order than default
% figure; 
% scatter(x,y1,45,c(3,:),'filled'); hold on;
% scatter(x,y2,45,c(4,:),'filled');
% scatter(x,y3,45,c(5,:),'filled');
% scatter(x,y4,45,c(6,:),'filled');
% abline
% 
% % specifiy marker face color after the fact
% figure; 
% h(1) = scatter(x,y1,'filled'); hold on;
% h(2) = scatter(x,y2,'filled');
% h(3) = scatter(x,y3,'filled');
% h(4) = scatter(x,y4,'filled');
% for n = 1:numel(h)
%     h(n).MarkerFaceColor = c(n+2,:);
% end
% abline
% 
% % change marker face color to none after the fact then modify
% % markeredgecolor
% figure; 
% h(1) = scatter(x,y1,'filled'); hold on;
% h(2) = scatter(x,y2,'filled');
% h(3) = scatter(x,y3,'filled');
% h(4) = scatter(x,y4,'filled');
% for n = 1:numel(h)
%     h(n).MarkerFaceColor = 'none';
%     h(n).MarkerEdgeColor = c(n+2,:);
% end
% abline
% 
% % opposite of above (confirmed setting edge to 'none' and to another color)
% figure; 
% h(1) = scatter(x,y1,'filled'); hold on;
% h(2) = scatter(x,y2,'filled');
% h(3) = scatter(x,y3,'filled');
% h(4) = scatter(x,y4,'filled');
% for n = 1:numel(h)
%     h(n).MarkerFaceColor = 'flat';
% %    h(n).MarkerFaceColor = c(n+2,:);
% %    h(n).MarkerEdgeColor = 'flat';
% %    h(n).MarkerEdgeColor = 'none';
%    h(n).MarkerEdgeColor = c(n+3,:);
% end
% abline
% 
% 
% % specify the colororder
% figure; 
% h(1) = scatter(x,y1,'filled'); hold on;
% h(2) = scatter(x,y2,'filled');
% h(3) = scatter(x,y3,'filled');
% h(4) = scatter(x,y4,'filled');
% set(gca,'ColorOrder',c(4:end,:));
% abline
% 
% % SWITCH TO PLOT TYPE MARKER
% 
% figure;
% plot(x,y1,'o'); hold on;
% plot(x,y2,'o');
% plot(x,y3,'o');
% plot(x,y4,'o');
% abline
% 
% figure;
% plot(x,y1,'o','Color',c(3,:)); hold on;
% plot(x,y2,'o','Color',c(4,:));
% plot(x,y3,'o','Color',c(5,:));
% plot(x,y4,'o','Color',c(6,:));
% abline
% 
% % my fix for this broke the two above (fixed it)
% figure;
% plot(x,y1,'o','MarkerEdgeColor',c(3,:)); hold on;
% plot(x,y2,'o','MarkerEdgeColor',c(4,:));
% plot(x,y3,'o','MarkerEdgeColor',c(5,:));
% plot(x,y4,'o','MarkerEdgeColor',c(6,:));
% abline
% 
% % 
% figure;
% plot(x,y1,'o','MarkerFaceColor',c(3,:),'MarkerEdgeColor',c(3,:)); hold on;
% plot(x,y2,'o','MarkerFaceColor',c(4,:),'MarkerEdgeColor',c(4,:));
% plot(x,y3,'o','MarkerFaceColor',c(5,:),'MarkerEdgeColor',c(5,:));
% plot(x,y4,'o','MarkerFaceColor',c(6,:),'MarkerEdgeColor',c(6,:));
% abline
% 
% % mix and match - works! (if marker face color matches edge)
% figure;
% plot(x,y1,'o','MarkerFaceColor','none','MarkerEdgeColor',c(3,:)); hold on;
% plot(x,y2,'o','MarkerFaceColor','none','MarkerEdgeColor',c(4,:));
% plot(x,y3,'o','MarkerFaceColor',c(1,:),'MarkerEdgeColor',c(5,:));
% plot(x,y4,'o','MarkerFaceColor',c(2,:),'MarkerEdgeColor',c(6,:));
% abline
% 
% % now try specifiying the colors
% figure; 
% scatter(x,y1); hold on;
% scatter(x,y2);
% scatter(x,y3);
% scatter(x,y4);
% abline(ab1(2),ab1(1),'Color',c(1,:));
% abline(ab2(2),ab2(1),'Color',c(2,:));
% abline(ab3(2),ab3(1),'Color',c(3,:));
% abline(ab4(2),ab4(1),'Color',c(4,:));

% now try not specifiying the colors
figure; 
scatter(x,y1); hold on;
scatter(x,y2);
scatter(x,y3);
scatter(x,y4);
abline(ab1(2),ab1(1));
abline(ab2(2),ab2(1));
abline(ab3(2),ab3(1));
abline(ab4(2),ab4(1));

figure; 
myscatter(x,y1,c(1,:)); hold on;
myscatter(x,y2,c(2,:));
abline;
abline(abL(2),abL(1));
abline(abL(2),abL(1),'Color',c(1,:))
abline(abH(2),abH(1),'Color',c(2,:))





% scatter(TGL,SGL,45,c(3,:),'filled'); hold on;
% scatter(TGH,SGH,45,c(4,:),'filled');
plot(x,y1,45,c(3,:),'filled'); hold on;
plot(x,y2,45,c(4,:),'filled');
abline(abL(2),abL(1));
abline(abL(2),abL(1),'Color',c(3,:))


% this works
figure; 
scatter(x,y1,45,c(3,:),'filled'); hold on;
scatter(x,y2,45,c(4,:),'filled');
abline

% this works b/c in this case, marker face color matches the edge color b/c
% the edge color is in the same default order
plot(x,y1,'o','MarkerFaceColor',c(1,:)); hold on;
plot(x,y2,'o','MarkerFaceColor',c(2,:)); hold on;
abline

% this reveals how it is necessary to choose which comes first - marker
% face color or just 'color' - I changed the code to check markerfacecolor
% first
plot(x,y1,'o','MarkerFaceColor',c(3,:)); hold on;
plot(x,y2,'o','MarkerFaceColor',c(4,:)); hold on;
abline
