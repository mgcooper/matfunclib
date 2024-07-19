function bbox = polyshapeBoundingBox(poly, kwargs)
   %POLYSHAPEBOUNDINGBOX Bounding box of polyshape, returned as a polyshape.
   %
   %  bbox = polyshapeBoundingBox(poly)
   %
   % Unlike `boundingbox`, this function returns a polyshape.
   %
   % See also: polyshape, boundingbox

   arguments
      poly polyshape
      kwargs.buffer = 0
      kwargs.plot = false
   end

   [xbox, ybox] = boundingbox(poly);

   ymin = min(ybox);
   ymax = max(ybox);
   xmin = min(xbox);
   xmax = max(xbox);

   xbox = [xmin xmax xmax xmin xmin];
   ybox = [ymin ymin ymax ymax ymin];

   bbox = polybuffer(polyshape(xbox, ybox), kwargs.buffer);

   if kwargs.plot
      figure
      plot(bbox)
   end
end
