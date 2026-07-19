function filled = floodFillInterior(binaryImage, startX, startY)
   %FLOODFILLINTERIOR Fill the interior region enclosed by a binary boundary.
   %
   %   filled = FLOODFILLINTERIOR(binaryImage, startX, startY) returns a
   %   binary image of the same size as binaryImage, true for cells enclosed
   %   by the true (boundary) region: cells that are neither boundary cells
   %   nor reachable by the exterior flood fill started at (startX, startY).
   %
   %   Example:
   %   binaryImage = [1 1 1 1;
   %                  1 0 0 1;
   %                  1 0 0 1;
   %                  1 1 1 1];
   %   filled = floodFillInterior(binaryImage, 1, 1);
   %
   %   The output 'filled' will be:
   %   [0 0 0 0;
   %    0 1 1 0;
   %    0 1 1 0;
   %    0 0 0 0]
   %
   % See also: floodFillExterior

   filled = ~floodFillExterior(binaryImage, startX, startY) & ~binaryImage;
end
