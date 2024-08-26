function [xlims, ylims] = boundingBoxLimits(B)

   if ispolyshape(B)
      [xlims, ylims] = boundingbox(B);
   else
      if isnumericmatrix(B)
         [X, Y] = deal(B(:, 1), B(:, 2));

      elseif isgeostruct(B)
         [Y, X] = geostructCoordinates(B, "geographic", "asarray");

      elseif ismapstruct(B)
         [X, Y] = geostructCoordinates(B, "projected", "asarray");
      end
      [~, xlims, ylims] = coordsToBbox(X, Y, 'aslimits', true);
   end
end
