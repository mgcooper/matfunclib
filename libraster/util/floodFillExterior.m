function filled = floodFillExterior(binaryImage, startX, startY)
%FLOODFILLEXTERIOR Fill the exterior region of a binary image.
%
%   filled = FLOODFILLEXTERIOR(binaryImage, startX, startY) fills the
%   exterior region of a binary image using a flood-fill algorithm. The
%   filling starts from the specified point (startX, startY). The output
%   'filled' is a binary image of the same size as the input 'binaryImage',
%   with the exterior region filled (set to true) and the interior region
%   unchanged.
%
%   Input arguments:
%   - binaryImage: A binary image with the region of interest set to true.
%   - startX, startY: The starting point (row and column indices) for the
%                     flood-fill algorithm.
%
%   Output:
%   - filled: A binary image with the exterior region filled.
%
%   Example:
%   binaryImage = [0 0 0 0;
%                  0 1 1 0;
%                  0 1 1 0;
%                  0 0 0 0];
%   startX = 1;
%   startY = 1;
%   filled = floodFillExterior(binaryImage, startX, startY);
%
%   The output 'filled' will be:
%   [1 1 1 1;
%    1 0 0 1;
%    1 0 0 1;
%    1 1 1 1]

% Pad the input binary image with a false border.
paddedImage = padarray(binaryImage, [1 1], false, 'both');

% Initialize variables and preallocate the deque.
filled = paddedImage;
[rows, cols] = size(paddedImage);
totalElements = rows * cols;

% Validate the starting point and check if it is inside the region.
if startX < 1 || startX > rows || startY < 1 || startY > cols
   return;
end

startIdx = sub2ind(size(paddedImage), startX, startY);
if paddedImage(startIdx) == true
   return;
end

% Initialize the deque and indices.
deque = zeros(1, totalElements, 'uint32');
deque(1) = startIdx;
dequeIdx = 1;
dequeEnd = 1;

% Define the neighbor offsets.
neighbors = [-1, 1, -rows, rows];

% Flood-fill algorithm.
while dequeIdx <= dequeEnd
   idx = deque(dequeIdx);
   dequeIdx = dequeIdx + 1;

   if filled(idx) == false
      filled(idx) = true;

      for neighborOffset = neighbors
         neighborIdx = idx + neighborOffset;
         if neighborIdx > 0 && neighborIdx <= totalElements
            dequeEnd = dequeEnd + 1;
            deque(dequeEnd) = neighborIdx;
         end
      end
   end
end

% Invert the filled image and remove padding.
filled = ~filled;
filled = filled(2:end-1, 2:end-1);
end
