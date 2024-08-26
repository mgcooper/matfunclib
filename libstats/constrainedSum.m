function parts = constrainedSum(parts, constraint)

   total = sum(round(parts));
   while total ~= constraint
      remainders = mod(parts, floor(parts));
      remainders(remainders == 0) = nan;
      remainders(remainders == 1) = nan;
      if total > constraint
         % round the smallest one down
         minmod = findglobalmin(remainders);
         parts(minmod) = floor(parts(minmod));

      elseif total < constraint
         % round the largest one up
         maxmod = findglobalmax(remainders);
         parts(maxmod) = ceil(parts(maxmod));
      end
      total = sum(round(parts));
   end
   parts = round(parts);
end
