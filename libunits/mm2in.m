function in = mm2in(mm)
   % Converts milimeters to inches

   if isempty(mm) ==1
      in = [];
   else
      in = m2ft(mm./1000).*12;
   end
end