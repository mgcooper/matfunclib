function [outputArg1,outputArg2] = untitled12(inputArg1,inputArg2)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
% make my own scalebar

% need to fix this up


xlims   =   get(gca,'xlim');
ylims   =   get(gca,'ylim');

xdif    =   xlims(:,2) - xlims(:,1);

xoffset =   xpct/100 .* xdif;

x       =   xlims(:,1) + xoffset;

ydif    =   ylims(:,2) - ylims(:,1);

yoffset =   ypct/100 .* ydif;

y       =   ylims(:,1) + yoffset;

h       =   text(x,y,textstr,varargin{:});


xpct = 79;
ypct = 7;
width = 10; % km

xdist = s1.XLim(2) - s1.XLim(1);
xstart = s1.XLim(1) + (xpct/100 * xdist);
xend = xstart + 10*1000;

ydist = s1.YLim(2) - s1.YLim(1);
ystart = s1.YLim(1) + (ypct/100 * ydist);

xcoords = xstart:1:xend;
ycoords = ystart.*ones(size(xcoords));
plot(xcoords,ycoords,'k');

mytextbox('10 km',xpct,ypct+5);
end

