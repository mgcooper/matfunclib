function varargout = image_tricks(varargin)
%IMAGE_TRICKS image tips and tricks

% if called with no input, open this file
if nargin == 0; open(mfilename('fullpath')); return; end

% just in case this is called by accident
narginchk(0,0)

%%

% one way tot make a mask
   [B,L] = bwboundaries(icemask.mask==1,'noholes');
   
   figure; plot(mask); hold on; 
   scatter(icemask.x(:),icemask.y(:),20,L(:),'filled'); colorbar;

   figure;
   imshow(label2rgb(L, @jet, [.5 .5 .5]))
   hold on
   for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
   end
   % might be able to use imerode or imdilate to expand the mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




clean
save_figs = false;

p.data  = '/Users/coop558/mydata/DATA/greenland/rio_behar/';
p.data  = [p.data 'CLASSIFICATION_2016_ORTHOMOSAICS/'];

% I created an imagedatastore of the surface classification from Johnny
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
imds    =   imageDatastore([p.data 'W*.tif']);


% if the raw image is shown, it is just all black:
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
img1    = readimage(imds,1); figure; imshow(img1,'Colormap','gray');

% gray2ind yields the same
[img1,cmap1]    = gray2ind(img1,4);
figure; imshow(img1,cmap1)

% mat2gray same
img1            = mat2gray(img1); 
figure; imshow(img1)

% the trick is first gray2ind, then mat2gray
img1            = readimage(imds,1); figure; imshow(img1);
img1            = mat2gray(img1); 
[img1,cmap1]    = gray2ind(img1,4);
imshow(img1,cmap1)
colormap(parula(4))

colorbar

