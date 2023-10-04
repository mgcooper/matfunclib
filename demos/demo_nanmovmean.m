t = T(152:200);
q = Q(152:200);

q([10,11,19,45]) = nan;

figure; plot(t,q); hold on;
plot(t,movmean(q,3))
plot(t,nanmovmean(q,3),':')
plot(t,nansmooth(q,3,1,0),':')
legend('data','movmean','nanmovmean','nansmooth')

find(isnan(movmean(q,3)))
find(isnan(nanmovmean(q,3)))
find(isnan(nansmooth(q,3,1,0)))

x = 2*pi*linspace(-1,1);
y = cos(x) + 0.25 - 0.5*rand(size(x));
y([5 30 40:43]) = NaN;

figure; plot(x,y); hold on;
plot(x,movmean(y,3))
plot(x,nanmovmean(y,3),':')
legend('data','movmean','nanmovmean')

% ys = nanmoving_average(yn,4);
% yi = nanmoving_average(yn,4,[],1);
% 
% figure; plot(x,yn,x,yi,'.',x,ys),  axis tight
% legend('noisy','smooth','without interpolation')

% figure; plot(t,q); hold on;
% plot(t,movmean(q,3))
% plot(t,nanmovmean(q,3),'--')
% plot(t,nanmoving_average(q,1),':')
% plot(t,moving(q,3),':')
% legend('data','movmean','nanmovmean','nanmoving_average','moving')

plot(t,smooth_maverage(q,1))

plot(t,moving_average(q,1))
plot(t,movingmean(q,3))
