
clean

% the main takeaway is that in this case, using 'mean' is basically
% identical to interpquant and when 'mean' is used, it doesn't gap-fill
% like 'interp' does, so just use 'mean'. It's taking the mean of values
% wihtin the new time bins, so it should effectively be nearest-neighbor
% unless there are multiple values in one bin, which will only be true for
% the 15-min values if I use 30-min, so while interpolation would be ideal,
% basically I am shifting the values to the nearest 15 or 30 min posting,
% and all I care about is the value and the timestep to compute the
% derivative

load('example_data');

% convert cfs to cms
data                 = renamevars(data,'dischargeCfs','discharge_cfs');
data.discharge_cms   = cfs2cms(data.discharge_cfs);

flags    = data.flag;
data     = removevars(data,{'flag','timezone'});

newstep  = hours(1/2);

% % continuous fifteen minute calendar - for reference
Tref     = tocol(data.Time(1):newstep:data.Time(end));

% interpolate using the tquant method
t        = data.Time;
v        = data.discharge_cfs;
Tquant   = interpquant(t,v,newstep);
Tquant   = renamevars(Tquant,'vq','discharge_cfs');
Tquant   = Tquant(1:end-1,:); % prob can fix this in the function

% interpolate using regular retime
Treg     = retime(data,'regular','linear','TimeStep',newstep);
Treg     = setnan(Treg,Treg.discharge_cfs<0);

% average using regular retime
Tavg     = retime(data,'regular','mean','TimeStep',newstep);

isregular(Tquant,'time')
isregular(Treg,'time')
isregular(Tavg,'time')

sum(isnan(Tquant.discharge_cfs))
sum(isnan(Treg.discharge_cfs))
sum(isnan(Tavg.discharge_cfs))


% compare tquant to original data
figure; 
h1    = plot(Tquant.Time,Tquant.discharge_cfs,'o'); hold on;
h2    = plot(data.Time,data.discharge_cfs,'o');
formatPlotMarkers('markersize',10,'suppliedline',h1)
formatPlotMarkers('markersize',10,'suppliedline',h2)
set(gca,'YScale','log')
legend('Tquant','original');

% compare built-in retime with interp (Treg) to original
figure; 
h1    = plot(Treg.Time,Treg.discharge_cfs,'o'); hold on;
h2    = plot(data.Time,data.discharge_cfs,'o');
formatPlotMarkers('markersize',10,'suppliedline',h1)
formatPlotMarkers('markersize',10,'suppliedline',h2)
set(gca,'YScale','log')
legend('Treg','original');

% compare built-in retime with 'mean' (Tavg) to original
figure; 
h1    = plot(Tavg.Time,Tavg.discharge_cfs,'o'); hold on;
h2    = plot(data.Time,data.discharge_cfs,'o');
formatPlotMarkers('markersize',10,'suppliedline',h1)
formatPlotMarkers('markersize',10,'suppliedline',h2)
set(gca,'YScale','log')
legend('Tavg','original');



% below here are extra tests i did but not as important as the ones above,
% main thing is 

% see this question, with sum it might be different than interp or mean,
% and he was able to write a 'specialsum' function so it worked as expected
% i.e. the big gaps didn't return zeros

% https://www.mathworks.com/matlabcentral/answers/875643-trying-to-use-retime-to-sum-daily-values-but-i-don-t-want-days-that-only-have-nan-values-to-become

% now see what happens with retime without 'regular'
test1    = retime(data,'hourly','mean');
test2    = retime(data,'hourly',@mean);
test3    = retime(data,'regular','mean','TimeStep',hours(1));
test4    = retime(data,'regular',@specialavg,'TimeStep',hours(1));




figure;
h1 = plot(Tavg.Time,Tavg.discharge_cfs,'o'); hold on; 
h2 = plot(data.Time,data.discharge_cfs,'o');
formatPlotMarkers('markersize',10,'suppliedline',h1)
formatPlotMarkers('markersize',10,'suppliedline',h2)
set(gca,'YScale','log')
legend('new data','old data');

figure; 
myscatter(Tavg.discharge_cfs,Tquant.vq(1:end-1));
addOnetoOne;



sum(isnan(test1.discharge_cfs))
sum(isnan(test2.discharge_cfs))
sum(isnan(test3.discharge_cfs))
sum(isnan(test4.discharge_cfs))
sum(isnan(Tavg.discharge_cfs))


figure; plot(test1.Time,test1.discharge_cfs,'o'); formatPlotMarkers('markersize',2)
figure; plot(test3.Time,test3.discharge_cfs,'o'); formatPlotMarkers('markersize',2)

figure; plot(Tavg.Time,Tavg.discharge_cfs,'o'); formatPlotMarkers('markersize',2)


test     = retime(data,'regular','fillwithmissing','TimeStep',hours(1/4),'fillwithmissing');

test     = retime(data,'regular','linear','TimeStep',hours(1/4));
