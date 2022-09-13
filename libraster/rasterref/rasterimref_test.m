
    % from MATLAB recipes for earth science, a method to georeference an
    % image:
    
    
    filename = 'AST_L1A_003_03082003080706_03242003202838.hdf';
%     hdftool('filename'); % function no longer exists
    f = hdfread('filename');
    
    I1 = hdfread(filename,'VNIR_Band3N','Fields','ImageData'); 
    I2 = hdfread(filename,'VNIR_Band2','Fields','ImageData'); 
    I3 = hdfread(filename,'VNIR_Band1','Fields','ImageData');
    
    
    I1 = adapthisteq(I1); I2 = adapthisteq(I2); I3 = adapthisteq(I3);
    naivasha_rgb = cat(3,I1,I2,I3);
    imshow(naivasha_rgb,'InitialMagnification',10)
    imwrite(naivasha_rgb,'naivasha.tif','tif')
    
    % the recommendation was to use hdftool to get the geodetic coordinates
    % of the four corners, so would need another method
    inputpoints(1,:) = [36.214332 -0.319922]; % upper left corner
    inputpoints(2,:) = [36.096003 -0.878267]; % lower left corner
    inputpoints(3,:) = [36.770406 -0.400443]; % upper right corner
    inputpoints(4,:) = [36.652213 -0.958743]; % lower right corner
    
    basepoints(1,:) = [1,1];            % upper left pixel
    basepoints(2,:) = [1,4200];         % lower left pixel
    basepoints(3,:) = [4100,1];         % upper right pixel
    basepoints(4,:) = [4100,4200];      % lower right pixel
    
    % fitgeotrans takes pairs of control points (inputpoints and
    % basepoints) to infer a spatial transformation matrix
    tform = fitgeotrans(inputpoints,basepoints,'affine');
    
    % determine the limits of the input for georeferencing
    xLimitsIn = 0.5 + [0 size(naivasha_rgb,2)];
    yLimitsIn = 0.5 + [0 size(naivasha_rgb,1)]; 
    % Add 0.5 to both xLimitsIn and yLimitsIn to prevent the edges of the
    % image from being truncated during the affine transformation
    
    % determine the limits of the output
    [XBounds,YBounds] = outputLimits(tform,xLimitsIn,yLimitsIn);
    
    % use imref2d to reference the image to a world coordinates
    Rout = imref2d(size(naivasha_rgb),XBounds,YBounds);
    
    
    % apply the affine transformation to the original RGB composite 
    newnaivasha_rgb = imwarp(naivasha_rgb,tform,'OutputView',Rout);
    
    
    % compute an appropriate grid for the image. Note the difference
    % between the MATLAB numbering convention and the common coding of maps
    % used in published literature. The north/south suffix is generally
    % replaced by a negative sign for south, whereas MATLAB coding
    % conventions require negative signs for north. 
    X = 36.096003 : (36.770406 - 36.096003)/4100 : 36.770406; 
    Y = -0.958743 : ( 0.958743 - 0.319922)/4200 : -0.319922;
    
    
    % By default, the function imshow inverts the latitude axis when images
    % are displayed by setting the YDir property to Reverse. To invert the
    % latitude axis direction back to normal, we need to set the YDir
    % property to Normal by typing   
   
    imshow(newnaivasha_rgb,'XData',X,'YData',Y,'InitialMagnification',10);
    axis on, grid on, set(gca,'YDir','Normal')
    xlabel('Longitude'), ylabel('Latitude')
    title('Georeferenced ASTER Image')
    
    % Export the image , for example using
    print -djpeg70 -r600 naivasha_georef.jpg
    
    
    % In the previous example we used the geodetic coordinates of the four
    % corners to georeference the ASTER image. The Image Processing Toolbox
    % also includes functions to automatically align two images that are
    % shifted and/or rotated with respect to each other, cover slightly
    % different areas, or have a different resolutions .
    
    clear
    image1 = imread('sugutavalley_1.tif'); 
    image2 = imread('sugutavalley_2.tif');
    
    % The function imregconfig creates optimizer and metric configurations
    % that we transfer into imregister to perform intensity-based image
    % registration
    [optimizer, metric] = imregconfig('monomodal');
    
    % where monomodal assumes that the images were captured by the same
    % sensor. We can use this configurations to calculate the spatial
    % transformation matrix tform using the transformation type affine, as
    % in the previous example.
    
    tform = imregtform(image2(:,:,1),image1(:,:,1),'affine',optimizer,metric);
    % This transformation can be applied to image2 in order to
    % automatically align it with image1.
    
    image2_reg = imwarp(image2,tform,'OutputView',imref2d(size(image1)));
    % We can compare the result with the original images using
    
    subplot(1,3,1), imshow(image1)
    subplot(1,3,2), imshow(image2)
    subplot(1,3,3), imshowpair(image1,image2_reg,'blend')
    print -djpeg70 -r600 sugutavalley_aligned.jpg


    % PICK UP ON PAGE 350 FOR AN EXAMPLE OF USING IMSHOW AND GINPUT TO
    % CLICK ON FOUR CORNERS TO DEFINE BASEPOINTS AND GEORECTIFY
    % AUTOMAGICALLY
    
    
    
    
    
    