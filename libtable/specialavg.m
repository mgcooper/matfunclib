function y = specialavg(x)
   if isempty(x)
      y = nan();
   else
      y = mean(x,'omitnan');
   end
end