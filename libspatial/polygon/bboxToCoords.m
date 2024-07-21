function [xcoords, ycoords] = bboxToCoords(varargin)
   %BBOXTOCOORDS Convert bounding box to coordinate lists.
   %
   %  [xcoords, ycoords] = bboxToCoords(bbox)
   %  [xcoords, ycoords] = bboxToCoords(xlim, ylim)
   %
   % This function converts the bounding box coordinates into lists of x and y
   % coordinates representing the corners of the rectangle defined by the
   % bounding box, traversed in a counter-clockwise direction starting from the
   % lower-left corner.
   %
   % Inputs:
   %   - bbox: A 2x2 numeric array, where the first column is [xmin, xmax]
   %           and the second column is [ymin, ymax]. Equivalently, the first
   %           row is [xmin ymin], and the second row is [xmax ymax]:
   %            [ xmin ymin
   %              xmax ymax ]
   %
   %   - xlim: A vector (row or column) of length 2, where xlim = [xmin, xmax].
   %   - ylim: A vector (row or column) of length 2, where ylim = [ymin, ymax].
   %
   % Linear Indices:          Row,Col Indices:
   % 1 3  1=xleft  3=ylow  |  1,1  1,2  1,1=xleft  1,2=ylow
   % 2 4  2=xright 4=yupp  |  2,1  2,2  2,1=xright 2,2=yupp
   %
   % Outputs:
   %   - xcoords: A vector of x coordinates of the rectangle.
   %   - ycoords: A vector of y coordinates of the rectangle.
   %
   % Example:
   %   [xcoords, ycoords] = bboxToCoords([1, 3; 2, 4])
   %   % xcoords will be [1, 2, 2, 1, 1]
   %   % ycoords will be [3, 3, 4, 4, 3]
   %
   % See also: plotbbox, coordsToBbox

   narginchk(1,2)
   if nargin == 1
      bbox = varargin{1};
      if ispolyshape(bbox)
         [xcoords, ycoords] = bbox.boundingbox();
         return
      end
      validateattributes(bbox, {'numeric'}, {'size',[2 2]}, mfilename, 'BBOX', 1)

   elseif nargin == 2
      xlim = varargin{1};
      ylim = varargin{2};
      validateattributes(xlim, {'numeric'}, {'numel', 2}, mfilename, 'XLIM', 1)
      validateattributes(ylim, {'numeric'}, {'numel', 2}, mfilename, 'YLIM', 2)
      bbox = [xlim(:) ylim(:)];
   end

   % Extract coordinates
   ylow = bbox(1,2);
   yupp = bbox(2,2);
   xleft = bbox(1,1);
   xright = bbox(2,1);

   % Define vertices counter-clockwise starting from the lower-left corner
   ycoords = [ylow,  ylow,   yupp,   yupp,  ylow];
   xcoords = [xleft, xright, xright, xleft, xleft];
end
