function varargout = centroid2box(xc, yc, xres, yres)
   %CENTROID2BOX Create a bounding box centered on X,Y with cell size x/yres.
   %
   % [box] = centroid2box(xc, yc, xres, yres) returns a polyshape object
   % representing a bounding box around the input X,Y coordinate pairs (xc, yc)
   % with the given X/Y cell size (xres, yres). The box vertices are ordered
   % counter-clockwise.
   %
   % [xbox, ybox] = centroid2box(xc, yc, xres, yres) returns the X and Y
   % coordinates of the bounding box as separate vectors.
   %
   % Input:
   %   xc   - X coordinate of the centroid (scalar or matrix)
   %   yc   - Y coordinate of the centroid (scalar or matrix)
   %   xres - X resolution (cell size) of the grid (scalar)
   %   yres - Y resolution (cell size) of the grid (scalar)
   %
   % Output:
   %   box  - Bounding box as a polyshape object (optional)
   %   xbox - X coordinates of the bounding box (optional)
   %   ybox - Y coordinates of the bounding box (optional)
   %
   % See also: polyshape

   % Calculate the X and Y coordinates of the bounding box
   xbox=[...
      min(xc(:)) - xres/2; ...    % lower left
      max(xc(:)) + xres/2; ...    % lower right
      max(xc(:)) + xres/2; ...    % upper right
      min(xc(:)) - xres/2; ...    % upper left
      min(xc(:)) - xres/2];       % lower left

   ybox=[...
      min(yc(:)) - yres/2; ...    % lower left
      min(yc(:)) - yres/2; ...    % lower right
      max(yc(:)) + yres/2; ...    % upper right
      max(yc(:)) + yres/2; ...    % upper left
      min(yc(:)) - yres/2];       % lower left

   % Return the output depending on the number of requested output arguments
   switch nargout
      case 1
         varargout{1} = polyshape(xbox, ybox);
      case 2
         varargout{1} = xbox;
         varargout{2} = ybox;
   end
end
