function [bbox, xbox, ybox] = coordsToBbox(xcoords, ycoords, option)
   %COORDSTOBBOX Convert coordinate lists back to a bounding box.
   %
   %  bbox = coordsToBbox(xcoords, ycoords)
   %  bbox = coordsToBbox(xcoords, ycoords, 'aspolyshape')
   %  [_, xbox, ybox] = coordsToBbox(_)
   %
   % Description:
   %   This function converts lists of x and y coordinates that describe a
   %   rectangle into a bounding box format: [xmin ymin; xmax ymax]. The
   %   function assumes the coordinates describe a rectangle aligned with
   %   coordinate axes, and takes the minimum and maximum of the provided
   %   coordinates to form the box.
   %
   % Inputs:
   %   xcoords - A numeric vector of x coordinates of the rectangle.
   %             The vector should form a closed loop, typically starting and
   %             ending at the same point.
   %   ycoords - A numeric vector of y coordinates of the rectangle, with the
   %             same length and ordering as xcoords.
   %   option  - A scalar text indicating the output format. Options are
   %             'asbbox' and 'aspolyshape'. The default value is 'asbbox'.
   %
   % Outputs:
   %   bbox - A 2x2 numeric array where the first row contains the minimum x and
   %          y coordinates, and the second row contains the maximum x and y
   %          coordinates. The format is [xmin ymin; xmax ymax].
   %
   % Example:
   %   bbox = coordsToBbox([1 2 2 1 1], [3 3 4 4 3])
   %   % bbox will be [1 3; 2 4]
   %
   %   bbox = coordsToBbox([1 2 2 1 1], [3 3 4 4 3], 'aspolyshape')
   %   % bbox will be a polyshape with 4x2 vertices
   %
   % See also: bboxToCoords

   if nargin < 3
      option = 'asbbox';
   end

   validateattributes(xcoords, ...
      {'numeric'}, {'vector'}, mfilename, 'xcoords', 1);
   validateattributes(ycoords, ...
      {'numeric'}, {'vector', 'size', size(xcoords)}, mfilename, 'ycoords', 2);
   assert(numel(xcoords) > 1)
   validatestring(option, {'asbbox', 'aspolyshape'}, mfilename, 'option', 3);

   % Construct the bounding box.
   xmin = min(xcoords);
   xmax = max(xcoords);
   ymin = min(ycoords);
   ymax = max(ycoords);

   bbox = [xmin ymin; xmax ymax];

   % Construct vertices beginning from lower left, tracing counter-clockwise.
   xbox = [bbox(1,1), bbox(2,1), bbox(2,1), bbox(1,1), bbox(1,1)];
   ybox = [bbox(1,2), bbox(1,2), bbox(2,2), bbox(2,2), bbox(1,2)];

   if strcmp(option, 'aspolyshape')
      bbox = polyshape(xbox, ybox);
   end
end

% function xycoordsToBbox(coords)
%
%    % This is just for reference in case I want the input to be a Nx2 matrix
%    % instead of xcoords, ycoords.
%
%    % Calculate bounding box from arbitrary polygon coordinates.
%    xmin = min(coords(:,1));
%    xmax = max(coords(:,1));
%    ymin = min(coords(:,2));
%    ymax = max(coords(:,2));
%    bbox = [xmin ymin; xmax ymax];
%
%    % Construct vertices beginning from lower left, tracing counter-clockwise.
%    xbox = [bbox(1,1), bbox(2,1), bbox(2,1), bbox(1,1), bbox(1,1)];
%    ybox = [bbox(1,2), bbox(1,2), bbox(2,2), bbox(2,2), bbox(1,2)];
% end
