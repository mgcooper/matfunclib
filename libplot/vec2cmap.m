function cmap = vec2cmap(vec,varargin)
   %VEC2CMAP maps a vector of data 'vec' onto a colormap 'cmap'
   %
   % Syntax:
   %
   %  cmap = VEC2CMAP(vec);
   %  cmap = VEC2CMAP(vec,'colormap',colormap);
   %  cmap = VEC2CMAP(vec,'name1',value1,'name2',value2);
   %  cmap = VEC2CMAP(___,method). Options: 'flag1','flag2','flag3'.
   %        The default method is 'flag1'.
   %
   % Author: Matt Cooper, Oct-03-2022, https://github.com/mgcooper

   [vec, cmapname, crange] = parseinputs(vec, mfilename, varargin{:});
   
   % Convert the input cmap argument to a numeric colormap
   cmap = colormap(cmapname);
   
   % Below was not commented out so I must not have finished this, I think below
   % is identical to above but maybe an older method
   % Generate the colormap
   %cmap = eval([cmapname '(256)']);
   
   % Normalize the values to be between 1 and 256
   vec(vec < crange(1)) = crange(1);
   vec(vec > crange(2)) = crange(2);
   valsN = round(((vec - crange(1)) ./ diff(crange)) .* 255)+1;
   
   % Convert any nans to ones
   valsN(isnan(valsN)) = 1;
   
   % Convert the normalized values to the RGB values of the colormap
   cmap = cmap(valsN, :);

end

%%

% Pick back up on this - it could be called 'anchorpoint' or similar - it
% anchors the two colormaps at zero, but could be any point, so if they have
% different dynamic range, you can still have the general color transition from
% negative to positive aligned without forcing the limits equal.
% 
% clims1 = [min(x1), max(x1)]; % Range of dataset 1
% clims2 = [min(x2), max(x2)]; % Range of dataset 2
% 
% % Get the standard 'parula' colormap
% parulamap = parula(64);
% 
% % Find the index of the color corresponding to zero in the wider range
% minclim = min(clims1(1), clims2(1));
% maxclim = max(abs(clims1(1)), abs(clims2(1)));
% izero = floor(32 * -minclim / maxclim) + 1;
% 
% % Create custom colormaps for both datasets by rescaling the 'parula' colormap
% cmap1 = interp1(linspace(clims1(1), clims1(2), size(parulamap, 1)), ...
%    parulamap, linspace(clims1(1), clims1(2), 64));
% cmap2 = interp1(linspace(clims2(1), clims2(2), size(parulamap, 1)), ...
%    parulamap, linspace(clims2(1), clims2(2), 64));
% 
% % Ensure that the zero values in both colormaps correspond to the same color
% cmap1(32, :) = parulamap(izero, :);
% cmap2(32, :) = parulamap(izero, :);

%% INPUT PARSER
function [vec, cmap, crange] = parseinputs(vec, funcname, varargin)

   defaultcmap = 'parula';
   defaultrange = [min(vec) max(vec)];
   
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('vec', @isnumeric);
   parser.addParameter('cmap', defaultcmap, @ischar);
   parser.addParameter('crange', defaultrange, @isnumeric);
   parser.parse(vec, varargin{:});
   
   cmap = parser.Results.cmap;
   crange = parser.Results.crange;
end

%    hsv=rgb2hsv(cm);
%    hsv(170:end,1)=hsv(170:end,1)+1; % hardcoded
%    cm_data=interp1(linspace(0,1,size(cm,1)),hsv,linspace(0,1,m));
%    cm_data(cm_data(:,1)>1,1)=cm_data(cm_data(:,1)>1,1)-1;
%    cm_data=hsv2rgb(cm_data);


%    CData is an indexing array that maps the data from its values to the
%    colormap. The smallest value in the data maps to the first index of the
%    colormap array, and  the largest value in the data maps to the last index
%    in the colormap array. Therefore, if we have the data, we create a
%    colormap and then we need to know which index of the colormap should map
%    onto the data. so we need to convert the data into indices

% x = 1:numel(vec)
%
% % idx = interp1()
%
%
% x        = [Mesh.(FaceMapping)];
% Cidx  = 1:numel(Mesh);
% xref     = linspace(min(x),max(x),length(Cidx));
% idx_x    = interp1(xref,Cidx,'nearest');
% % then you can map to whatever colormap you want, e.g.
% graymap = gray(length(Cidx));
% xcolors = graymap(idx_x,:);

% grayImage = imread('pout.tif');
%
% subplot(2,2,1);
% imshow(grayImage);
% fontSize = 14;
% title('Gray Scale Image', 'FontSize', fontSize);
%
% subplot(2,2,2);
% imhist(grayImage);
% grid on;
% title('Histogram', 'FontSize', fontSize);
%
% % Define range of gray levels that the colormap should go between.
% grayLevelRange = [75, 150]; % Whatever you want.
% cmap = jet(256);
%
% % Specify color for gray levels below the specified range.
% cmap1 = repmat(cmap(1,:), [grayLevelRange(1), 1]);
%
% % Let the middle part be remapped such that the full colormap
% % covers the specified gray level range.
% cmap2 = imresize(cmap, [abs(grayLevelRange(2) - grayLevelRange(1) + 1), 3]);
%
% % Specify color for gray levels above the specified range.
% cmap3 = repmat(cmap(end, :), [255 - grayLevelRange(2), 1]);
%
% % Combine to form a new colormap.
% cmap = [cmap1; cmap2; cmap3];
%
% % Apply the colormap to the gray scale image to form an RGB image.
% rgbImage = ind2rgb(grayImage, cmap);
%
% % Display the RGB image.
% subplot(2, 2, 3);
% imshow(rgbImage);
% title('RGB Color-Mapped Image', 'FontSize', fontSize);
%
%
%
%
%
%












