function intercept = reflineintercept(x,y,slope,refpoint,modeltype,xyref)
   %REFLINEINTERCEPT Compute intercept of line passing through a reference point
   %
   % intercept = reflineintercept(x,y,slope,refpoint,'linear')
   % intercept = reflineintercept(x,y,slope,refpoint,'power')
   % intercept = reflineintercept(_, 'x')
   %
   % This function works by finding the value of the x or y-data that is nearest
   % to the refpoint, then finds the corresponding x or y-value, then forces the
   % line to pass through that point. The default assumption is that the
   % reference point is along the y-data, and the function finds the matching
   % x-value to construct the x-y pair refpoint.
   %
   % See also:

   if nargin < 6
      xyref = 'y';
   end

   switch xyref

      case 'y'

         switch modeltype

            case 'power'
               intercept = refpoint/x(findglobalmin(abs(y-refpoint),1,'first'))^slope;

               % % this finds all points within a neighborhood of refpoint
               % ydiffs = abs(y-refpoint);
               % ymean = mean(y,'omitnan');
               % yref = mean(y(ydiffs./ymean<0.15),'omitnan');
               % xref = mean(x(ydiffs./ymean<0.15),'omitnan');
               % intercept = yref/xref^slope;

            case 'linear'
               intercept = refpoint - ...
                  x(findglobalmin(abs(y-refpoint),1000,'first')) * slope;
         end

      case 'x'

         switch modeltype

            case 'power'
               intercept = ...
                  y(findglobalmin(abs(y-refpoint),1,'first')) / refpoint^slope;

               % might be better to use this, but it doesn't work if mask
               % intercept = yrefpoint/mean(x.^slope);

            case 'linear'
               intercept = ...
                  y(findglobalmin(abs(y-refpoint),1,'first')) - refpoint*slope;
         end
   end
end
