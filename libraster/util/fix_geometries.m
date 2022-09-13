
function S = fix_geometries(varargin)
    
    latopts = {'Lat','Latitude','lat','latitude'};
    lonopts = {'Lon','Longitude','lon','longitude'};
    xopts   = {'X','x'};
    yopts   = {'Y','y'};
        
    if nargin == 1 && isstruct(varargin{1})
        
        S       = varargin{1};
        fnames  = fieldnames(S);
        
        ilat    = ismember(fnames,latopts);
        ilon    = ismember(fnames,lonopts);
        iy      = ismember(fnames,yopts);
        ix      = ismember(fnames,xopts);
            
        if sum(ilat)>=1 && sum(ilon)>=1

            flat    = fnames{find(ilat)};
            flon    = fnames{find(ilon)};
            S       = geofix_geom(S,flat,flon);
            
        end
            
        if sum(iy)>=1 && sum(ix)>=1
            
            fx      = fnames{find(ix)};
            fy      = fnames{find(iy)};
            S       = mapfix_geom(S,fx,fy);

           %x       = S(n).(fnames{find(ix)});
           %y       = S(n).(fnames{find(iy)});
        end
        
        if sum(ilat)>=1 && sum(ilon)>=1 && sum(iy)>=1 && sum(ix)>=1
            
            disp('provided structure contains x,y and lat,lon data');
        end
    
    elseif nargin == 2 && ~isstruct(varargin{1})
        
        var1    = inputname(1);
        var2    = inputname(2);
        fnames  = {var1,var2};
        
        ilat    = ismember(fnames,latopts);
        ilon    = ismember(fnames,lonopts);
        iy      = ismember(fnames,yopts);
        ix      = ismember(fnames,xopts);
        
        if sum(ilat)>=1 && sum(ilon)>=1
            flat    = fnames{find(ilat)};
            flon    = fnames{find(ilon)};
            
            S.(flat)    = varargin{find(ilat)};
            S.(flon)    = varargin{find(ilon)};
            
            S           = geofix_geom(S,flat,flon);
            
        end
            
        if sum(iy)>=1 && sum(ix)>=1
            
            fx      = fnames{find(ix)};
            fy      = fnames{find(iy)};
            
            S.(fx)  = varargin{find(ix)};
            S.(fy)  = varargin{find(iy)};
            
            S       = mapfix_geom(S,fx,fy);
        
        end
    end
end

function S = geofix_geom(S,flat,flon);
    
    for n = 1:numel(S)

        lat         = S(n).(flat);
        lon         = S(n).(flon);
           
        inanlat     = isnan(lat) & ~isnan(lon);
        inanlon     = isnan(lon) & ~isnan(lat);

        if any(inanlat) | any(inanlon)
            inan    = inanlat + inanlon;
            lat     = lat(~inan);
            lon     = lon(~inan);
        end

        ibad        = isinf(lat) | isinf(lon) | lat==0 | lon==0;
        lat(ibad)   = [];
        lon(ibad)   = [];


        [lat,lon]   = closePolygonParts(lat,lon,'degrees');
        [lon,lat]   = removeExtraNanSeparators(lon,lat);

        % check again
        ibad        = isinf(lat) | isinf(lon) | lat==0 | lon==0;
        lat(ibad)   = [];
        lon(ibad)   = [];

%         if any(ibad)
%             lat     = lat(~ibad);
%             lon     = lon(~ibad);
%             break
%         end

        S(n).(flat) = lat;
        S(n).(flon) = lon;

    %     not sure if these should be added:
    %     isShapeMultipart(x,y);
    %     ispolycw(lon,lat)
    %     [lon,lat]   = poly2cw(lon,lat);figure; plot(lon,lat);

    % flatearthpoly - fix longitude discontinuties at date line crossings
    % reducem - simplifies polygon and line data

    % see 'Simplify Vector Coordinate Data' in the docs
    % see functions in computational geometry, rmslivers, rmboundaries

    % for rio behar, it was helpful to use polysplit

    % for ispolycw:
    % You can use ispolycw for geographic coordinates if the polygon does not
    % cross the Antimeridian or contain a pole. A polygon contains a pole if
    % the longitude data spans 360 degrees. To use ispolycw with geographic
    % coordinates, specify the longitude vector as x and the latitude vector as y.    

    end
    
end

function S = mapfix_geom(S,fx,fy);
    
    for n = 1:numel(S)

        x       = S(n).(fx);
        y       = S(n).(fy);
           
        inanx   = isnan(x) & ~isnan(y);
        inany   = isnan(y) & ~isnan(x);

        if any(inanx) | any(inany)
            inan    = inanx + inany;
            x       = x(~inan);
            y       = y(~inan);
        end

        ibad        = isinf(x) | isinf(y) | x==0 | y==0;

        x(ibad)     = [];
        y(ibad)     = [];


        [x,y]   = closePolygonParts(x,y);
        [x,y]   = removeExtraNanSeparators(x,y);

        % check again
        ibad        = isinf(x) | isinf(y) | x==0 | y==0;
        
        x(ibad)     = [];
        y(ibad)     = [];

        S(n).(fx)   = x;
        S(n).(fy)   = y;
    end 
end