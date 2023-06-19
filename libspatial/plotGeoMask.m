function plotGeoMask(matrix, x, y, varargin)
% function plotGeoMask(matrix, varargin)

if nargin == 4
% if nargin == 2
   plottype = varargin{1};
else
   plottype = 'image';
end


switch plottype
   case "lines"
      plotGeoMaskAsLines(matrix);
   case "image"
      plotGeoMaskAsImage(matrix);
   case "scatter"
      plotGeoMaskScatter(matrix);
   case "downsample"
      plotGeoMaskDownSample(matrix);
   case "dilate"
%       plot_geo_mask_dilated(matrix);
      plot_geo_mask_dilated(matrix,x,y);
end

end

% function plot_geo_mask_dilated(matrix)
%     % Define the structuring element for dilation
%     se = strel('square', 3);
%     
%     % Dilate the matrix
%     dilated_matrix = imdilate(matrix, se);
%     
%     % Display the matrix as an image
%     imshow(~dilated_matrix, 'InitialMagnification', 'fit');
% 
%     % Modify the colormap to 'gray' and invert it to have white features on black background
%     colormap(flipud(gray(256)));
% end

function plot_geo_mask_dilated(matrix, x, y)
    % Define the structuring element for dilation
    se = strel('square', 3);
    
    % Dilate the matrix
    dilated_matrix = imdilate(matrix, se);
    
    % Display the matrix as an image with spatial referencing
    imagesc(x, y, ~dilated_matrix);
    
    % Modify the colormap to 'gray' and invert it to have white features on black background
    colormap(flipud(gray(256)));
    
    % Make sure the aspect ratio of the axes is correct
    axis image;
    
    % Set background to black
    set(gca,'Color','k');
    
    % Reverse the y-axis direction if necessary
    set(gca,'YDir','normal');
end


% function plot_geo_mask_dilated(matrix, x, y)
%     % Define the structuring element for dilation
%     se = strel('square', 3);
%     
%     % Dilate the matrix
%     dilated_matrix = imdilate(matrix, se);
%     
%     % Display the matrix as an image with spatial referencing
%     %imshow(x, y, ~dilated_matrix, 'InitialMagnification', 'fit');
%     
%     %mapshow(x, y, dilated_matrix, 'DisplayType','texturemap');
%     mapshow(x, y, ~dilated_matrix, 'DisplayType','image');
%     
%     % Modify the colormap to 'gray' and invert it to have white features on black background
%     colormap(flipud(gray(256)));
% %     colormap(gray(256));
%     
%     % dilated_matrix, flipud(gray(256)), solid black
%     % dilated_matrix, gray(256), solid black
%     
%     % ~dilated_matrix, flipud(gray(256)), white 0s, black 1s
%     % ~dilated_matrix, gray(256), white 0s, black 1s
%     
% end


function plotGeoMaskAsImage(matrix)

% Plot the matrix using imagesc
imagesc(matrix);

% Use a colormap that clearly differentiates land and water
% colormap([0 0 1; 0 1 0]);  % Blue for water, green for land
colormap([0 0 0; 1 1 1]);  % Blue for water, green for land

% Optionally, you might want to hide the axes for a cleaner plot
axis off;

% Add colorbar for reference
colorbar;
end


function plotGeoMaskAsLines(matrix)
% Use bwboundaries to find the boundaries of the 1s
boundaries = bwboundaries(matrix);

% Create a new figure
figure;
hold on;

% Loop over each set of boundaries and plot it as a line
for i = 1:length(boundaries)
   boundary = boundaries{i};
   plot(boundary(:,2), boundary(:,1), 'LineWidth', 2);
end

% Reverse the y-axis so that the plot orientation matches the matrix orientation
set(gca, 'YDir', 'reverse');

% Hide the axes
axis off;

hold off;
end


function plotGeoMaskScatter(matrix)
    % Find the indices of the 1s in the matrix
    [rows, cols] = find(matrix);
    
    % Create a scatter plot of the 1s
    scatter(cols, -rows, [], 'k', 'filled', 's');
    
    % Hide the axes
    axis off;
end

function plot_geo_mask_large(matrix)
    % Find the indices of the 1s in the matrix
    [rows, cols] = find(matrix);

    % Create a figure with black background
    fig = figure('Color', 'k');
    
    % Create a scatter plot of the 1s
    %scatter(cols, -rows, [], 's', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'w', 'filled');
    scatter(cols, -rows, [], 'k', 'filled', 's');
    
    % Hide the axes and set their color to black
    ax = gca;
    ax.Color = 'k';
    ax.XColor = 'k';
    ax.YColor = 'k';
    ax.Visible = 'off';
end


function plotGeoMaskDownSample(matrix)
    % Downsample the matrix using imresize (change the 0.1 to whatever downsampling factor you want)
    matrix_downsampled = imresize(matrix, 0.1, 'nearest');
    
    % Plot the downsampled matrix using imagesc
    imagesc(matrix_downsampled);
    
    % Change the colormap to make the 1s stand out
    % colormap([1 1 1; 0 0 0]); % white for 0s, black for 1s
    colormap([0 0 0; 1 1 1]); % white for 0s, black for 1s
    
    % Hide the axes
    axis off;
end




