function ltxt = num2ltext(prfx,sym,num,unit,precision)

str = [prfx ' $' sym '=%.' num2str(precision) 'f$ ' unit ];
ltxt = cellstr(num2str(num', str));

% for reference, this would convert exponential ticklabels to fixed point
% set(gca, "YTickLabels", compose('%s', string(get(gca, "YTick"))))