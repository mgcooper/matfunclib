function [ x,y ] = text_coords( xpct,ypct)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

xlims   =   get(gca,'xlim');
ylims   =   get(gca,'ylim');

xdif    =   xlims(:,2) - xlims(:,1);

xoffset =   xpct/100 .* xdif;

x       =   xlims(:,1) + xoffset;

ydif    =   ylims(:,2) - ylims(:,1);

yoffset =   ypct/100 .* ydif;

y       =   ylims(:,1) + yoffset;





end

