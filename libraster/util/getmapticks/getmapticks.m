function ticks = getmapticks(axlow,axhigh,latticks,lonticks,proj)

% latticks    = [66.8 67.0 67.2];
% lonticks    = [-51.0 -50.0 -49.0 -48.0 -47.0];

ntickslat   = length(latticks);
ntickslon   = length(lonticks);

% x-y limits of map axis
xlims       = get(axlow,'xlim');
ylims       = get(axlow,'ylim');

% lat-lon limits of map axis
[latlims, ...
 lonlims]   = projinv(proj,xlims,ylims);

% lat-lon limits of map corners
[latLL, ...
 lonLL]     = projinv(proj,xlims(1),ylims(1));
[latUL, ...
 lonUL]     = projinv(proj,xlims(1),ylims(2));
[latUR, ...
 lonUR]     = projinv(proj,xlims(2),ylims(2));
[latLR, ...
 lonLR]     = projinv(proj,xlims(2),ylims(1));

% the projected ticks will be located at the request latticks on the x-axis
% can we can use a dummy lon value to get the location of the latitude
% ticks? NOPE - this is where the problem lies. I need to figure out how to
% fix it from here ... i know the corners, so I can figure it out
londums     = lonlims(1).*ones(1,ntickslat);

[~,yticksL] = projfwd(proj);


% get the utm values for the desired y ticks on the left/right axes
[~,yticksL]  = projfwd(proj,latticks,londums);
[~,yticksR] = projfwd(proj,latticks, ...
            [lonlims(2) lonlims(2) lonlims(2)]);

% get the utm values for the desired x ticks on the low/high axes
[fmt.xtickslow,~]   = projfwd(proj,[latlims(1)          ...
latlims(1) latlims(1) latlims(1) latlims(1)], ... 
                        lonticks);
[fmt.xtickshigh,~]  = projfwd(proj,[latlims(2)          ...
latlims(2) latlims(2) latlims(2) latlims(2)], ... 
                        lonticks);

fmt.xticklabels     = {'51.0 ^oW','50.0 ^oW','49.0 ^oW','48.0 ^oW'};
fmt.yticklabels     = {'66.8 ^oN','67.0 ^oN','67.2 ^oN'};


% we don't have ticks yet, so this just verifies
xtickslow   = get(axlow,'xtick');
yticksL  = get(axlow,'ytick');
xtickshigh  = get(axhigh,'xtick');
yticksR = get(axhigh,'xtick');

[~,ln] = projinv(proj,xtickslow(1),ylims(1))
[lt,~] = projinv(proj,xlims(1),yticksL(1))



