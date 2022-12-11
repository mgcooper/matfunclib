function ltxt = num2ltext(prfx,sym,num,unit,precision)

str   = [prfx ' $' sym '=%.' num2str(precision) 'f$ ' unit ];
ltxt  = cellstr(num2str(num', str));