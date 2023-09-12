clean

% Create a blank binary image.
binaryImage = ones(100, 100);

% Create an irregular "island" in the image.
island = false(size(binaryImage));
island(40:60, 40:60) = 1;
se = strel('disk', 10);
erodedIsland = imerode(island, se);
binaryImage(erodedIsland) = 0;

% Plot the original binary image with a boundary.
subplot(1, 2, 1);
imshow(binaryImage);
hold on;
boundary = bwperim(binaryImage, 8);
[row, col] = find(boundary);
plot(col, row, 'g', 'LineWidth', 2);
hold off;
title('Original Image');

% Apply the flood fill function from the top-left corner.
filled = floodFillExterior(binaryImage, 1, 1);

% Plot the filled image with a boundary.
subplot(1, 2, 2);
imshow(filled);
hold on;
boundaryFilled = bwperim(filled, 8);
[rowFilled, colFilled] = find(boundaryFilled);
plot(colFilled, rowFilled, 'r', 'LineWidth', 2);
hold off;
title('Filled Image');

%%

% Define a demonstration binary image.
binaryImage = ones(50, 50);

% Create an "island" in the middle of the image.
binaryImage(20:30, 20:30) = 0;

% Plot the original binary image.
subplot(1, 2, 1);
% imshow(binaryImage);
plotraster(binaryImage);
title('Original Image');

% Apply the flood fill function from the top-left corner.
filled = floodFillExterior(binaryImage, 1, 1);

% Plot the filled image.
subplot(1, 2, 2);
imshow(filled);
title('Filled Image');
