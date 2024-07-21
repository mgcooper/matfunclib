function [bbox, xbox, ybox] = xylimsToBbox(xlims, ylims)
   %XYLIMSTOBBOX
   %
   %  h = xylimsToBbox(xlims, ylims)
   %  h = xylimsToBbox(xlims, ylims)
   %
   % Description
   %
   %  h = xylimsToBbox(xlims, ylims) constructs a bounding box from x and y
   %  extents specified by XLIMS and YLIMS. XLIMS and YLIMS are two-element
   %  vectors (row or column) whose first elements correspond to lower x and
   %  y bounds, and whose second elements correspond to upper x and y bounds.
   %
   % Note: This is a convenience function to illustrate the conversion between
   % xlims and ylims and bounding box format. Use the coordsToBbox function for
   % general purposes.
   %
   % See also:

   % Construct a bounding box in the format used by Mapping Toolbox
   bbox = [xlims(:), ylims(:)];

   % 1 3  1=xleft  3=ylow  |  1,1  1,2  1,1=xleft  1,2=ylow
   % 2 4  2=xright 4=yupp  |  2,1  2,2  2,1=xright 2,2=yupp

   % Construct vertices beginning from lower left tracing ccw.
   xbox = [bbox(1), bbox(2), bbox(2), bbox(1), bbox(1)];
   ybox = [bbox(3), bbox(3), bbox(4), bbox(4), bbox(3)];
end
