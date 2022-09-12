function setcolors(p,colors)
%SETCOLORS Sets the color of each line in p to the colors in colors
%   Input:  nx1 plot handle object
%           nx3 color triplet array

for n = 1:length(p)
    p(n).Color = colors(n,:);
end
end

