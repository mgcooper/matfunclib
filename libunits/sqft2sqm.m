function sqm = sqft2sqm(sqft)
   % Convert square feet to square meters
   if nargin < 1
      sqm = [];
   else
      sqm = sqft ./ 3.28083989501 ^ 2;
   end
end
