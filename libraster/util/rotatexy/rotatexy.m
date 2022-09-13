function [xr,yr] = rotatexy(x,y,ang)
    
    xr = x.*cosd(ang)-y.*sind(ang);
    yr = x.*sind(ang)+y.*cosd(ang);
end