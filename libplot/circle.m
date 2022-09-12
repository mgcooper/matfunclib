function [xcirc,ycirc] = circle(x,y,r)
theta = linspace(0,2*pi);
xcirc = r*cos(theta)+x;
ycirc = r*sin(theta)+y;
end

% function [h,xcirc,ycirc] = circle(x,y,r)
% hold on
% theta = linspace(0,2*pi);
% xcirc = r*cos(theta)+x;
% ycirc = r*sin(theta)+y;
% h = plot(xcirc,ycirc);
% hold off
% end

