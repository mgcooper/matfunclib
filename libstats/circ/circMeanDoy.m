function meanDay = circMeanDoy(daysOfYear, isLeapYear)
   %CIRCMEANDOY Compute mean day of the year using circular statistics
   
   if nargin < 2
      isLeapYear = false;
   end
   if isLeapYear
      maxDays = 366;
   else
      maxDays = 365;
   end
   radians = (daysOfYear - 1) * (2 * pi / maxDays);

   % Compute mean cosine and sine of the angles
   meanCos = mean(cos(radians));
   meanSin = mean(sin(radians));

   % Compute mean angle in radians, taking care of the arctan quadrants
   meanAngle = atan2(meanSin, meanCos);

   % Ensure positive angle for negative mean angles
   if meanAngle < 0
      meanAngle = meanAngle + 2 * pi;
   end

   % Convert mean angle back to mean day of the year
   meanDay = (meanAngle / (2 * pi)) * maxDays;
end
