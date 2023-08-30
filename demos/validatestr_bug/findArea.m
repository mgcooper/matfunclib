function a = findArea(shape,h,w,units)
    expectedShapes = {'square','rectangle','triangle'};
    expectedUnits = {'cm','m','in','ft','yds'};
    
    shapeName = validatestring(shape,expectedShapes,1);
    unitAbbrev = validatestring(units,expectedUnits,mfilename,'units',4);
    
    switch shapeName
        case {'square','rectangle'}
            a = h*w;
        case {'triangle'}
            a = h*w/2;
        otherwise
            error('Unknown shape passing validation.')
    end
end