function y = specialinterp(x)
   if isempty(x)
      y = nan();
   else
      y = interp1(x);
   end
end