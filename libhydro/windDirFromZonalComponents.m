function [ windSpd, windDir ] = windDirFromZonalComponents( u, v )
%WINDDIRFROMZONALCOMPONENTS compute wind direction from zonal wind component
%vectors u and v.
% 
%  [windSpd,windDir] = windDirFromZonalComponents(u,v)
% 
% See also

windSpd = sqrt(u.^2 + v.^2);
windDir = atan2(u./windSpd, v./windSpd);
windDir = windDir.*180/pi + 180;