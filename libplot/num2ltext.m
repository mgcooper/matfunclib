function ltxt = num2ltext(prfx, sym, num, unit, precision)

   if ~isoctave
      [prfx, sym, num, unit, precision] = convertStringsToChars( ...
         prfx, sym, num, unit, precision);
   end

   str = [prfx ' $' sym '=%.' num2str(precision) 'f$ ' unit ];
   ltxt = cellstr(num2str(num', str));

   if isoctave
      ltxt = latex2tex(ltxt);
   end
   
   % for reference, this would convert exponential ticklabels to fixed point
   % set(gca, "YTickLabels", compose('%s', string(get(gca, "YTick"))))
end