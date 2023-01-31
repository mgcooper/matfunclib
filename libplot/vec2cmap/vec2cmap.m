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

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

defaultcmap       = 'parula';
defaultrange      = [min(vec) max(vec)];

p.addRequired(   'vec',                   @(x)isnumeric(x)  );
p.addParameter(  'cmap',   defaultcmap,   @(x)ischar(x)     );
p.addParameter(  'crange', defaultrange,  @(x)isnumeric(x)  );

p.parseMagically('caller');

cmap = p.Results.cmap;
%------------------------------------------------------------------------------

% convert the input cmap argument to a numeric colormap
cmap = colormap(cmap);

% Generate the colormap
cmap = eval([cmap '(256)']);

% Normalize the values to be between 1 and 256
vec(vec < crange(1)) = crange(1);
vec(vec > crange(2)) = crange(2);
valsN = round(((vec - crange(1)) ./ diff(crange)) .* 255)+1;

% Convert any nans to ones
valsN(isnan(valsN)) = 1;

% Convert the normalized values to the RGB values of the colormap
cmap = cmap(valsN, :);



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












