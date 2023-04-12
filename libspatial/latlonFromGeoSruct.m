function [Lat,Lon] = latlonFromGeoSruct(Geom,outputType,opts)
%LATLONFROMGEOSRUCT general description of function
%
%  [Lat,Lon] = LATLONFROMGEOSRUCT(Geom) description
%  [Lat,Lon] = LATLONFROMGEOSRUCT(Geom,'flag1') description
%  [Lat,Lon] = LATLONFROMGEOSRUCT(Geom,'flag2') description
%  [Lat,Lon] = LATLONFROMGEOSRUCT(___,'opts.name1',opts.value1,'opts.name2',opts.value2)
%  description. The default flag is 'plot'.
%
% Example
%
%
% Matt Cooper, 06-Apr-2023, https://github.com/mgcooper
%
% See also


%% input parsing
arguments
   Geom (:,:) struct
   outputType (1,1) string {mustBeMember(outputType,["ascell","asarray"])} = "asarray"
   opts.LineStyle (1,1) string = "-"
   opts.LineWidth (1,1) {mustBeNumeric} = 1
end

% use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
varargs = namedargs2cell(opts);

% simple, but doesn't check for nan-separators
% Lat = [S(:).Lat];
% Lon = [S(:).Lon];
   
[Lat,Lon] = getlatlon({Geom.Lat},{Geom.Lon});

if outputType == "ascell"
   % need to implement ascell method
   % [lat,lon] = polyjoin(lat,lon);
end

function [lat,lon] = getlatlon(latcells,loncells)
%getlatlon Convert line or polygon parts from cell arrays to vector form
% 
%   [LAT,LON] = POLYJOIN(LATCELLS,LONCELLS) converts polygons from cell
%   array format to column vector format.  In cell array format, each
%   element of the cell array is a vector that defines a separate polygon.
%   A polygon may consist of an outer contour followed by holes separated
%   with NaNs.  In vector format, each vector may contain multiple faces
%   separated by NaNs.  There is no structural distinction between outer
%   contours and holes in vector format.

if isempty(latcells) && isempty(loncells)
    lat = reshape([], [0 1]);
    lon = lat;
else
    validateattributes(latcells,{'cell'},{'vector'},mfilename,'LATCELLS',1)
    validateattributes(loncells,{'cell'},{'vector'},mfilename,'LONCELLS',2)
    
    assert(isequal(size(latcells),size(loncells)), ...
        'libspatial:latlonFromGeoSruct:cellvectorSizeMismatch', ...
        '%s and %s must match in size.', ...
        'LATCELLS', 'LONCELLS')
    
    latSizes = cellfun(@size, latcells, 'UniformOutput', false);
    lonSizes = cellfun(@size, loncells, 'UniformOutput', false);
    
    assert(isequal(latSizes,lonSizes), ...
        'libspatial:latlonFromGeoSruct:cellContentSizeMismatch', ...
        'Contents of corresponding cells in %s and %s must match in size.', ...
        'LATCELLS', 'LONCELLS')
    
    M = numel(latcells);
    N = 0;
    for k = 1:M
        N = N + numel(latcells{k});
    end
    
    lat = zeros(N + M - 1, 1);
    lon = zeros(N + M - 1, 1);
    p = 1;
    for k = 1:(M-1)
        q = p + numel(latcells{k});
        lat(p:(q-1)) = latcells{k};
        lon(p:(q-1)) = loncells{k};
        lat(q) = NaN;
        lon(q) = NaN;
        p = q + 1;
    end
    if M > 0
        lat(p:end) = latcells{M};
        lon(p:end) = loncells{M};
    end
end
