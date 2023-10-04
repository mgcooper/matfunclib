function out = imageSizeInXY(im)
    arguments
        im (1,1) matlab.graphics.primitive.Image = findimage
    end
 
    pixel_width = extent(im.XData,size(im.CData,2));
    pixel_height = extent(im.YData,size(im.CData,1));
 
    x1 = im.XData(1) - (pixel_width / 2);
    x2 = im.XData(end) + (pixel_width / 2);
 
    y1 = im.YData(1) - (pixel_height / 2);
    y2 = im.YData(end) + (pixel_height / 2);
 
    out = [(x2 - x1) (y2 - y1)];
end
 
function im = findimage
    image_objects = imhandles(imgca);
    if isempty(image_objects)
        error("No image object found.");
    end
    im = image_objects(1);
end
 
function e = extent(data,num_pixels)
    if (num_pixels <= 1)
        e = 1;
    else
        e = (data(2) - data(1)) / (num_pixels - 1);
    end
end
