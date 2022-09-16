function [ windSpd, windDir ] = windDirFromZonalComponents( u, v )
%WINDDIRFROMZONALCOMPONENTS

windSpd = sqrt(u.^2 + v.^2);
windDir = atan2(u./windSpd, v./windSpd);
windDir = windDir.*180/pi + 180;

end

