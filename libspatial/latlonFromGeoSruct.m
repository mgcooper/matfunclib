function [Lat,Lon] = latlonFromGeoSruct(Geom,outputType)
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
   % opts.LineStyle (1,1) string = "-"
   % opts.LineWidth (1,1) {mustBeNumeric} = 1
end

% use this to create a varargin-like optsCell e.g. plot(c,optsCell{:});
% varargs = namedargs2cell(opts);

% simple, but doesn't check for nan-separators
% Lat = [S(:).Lat];
% Lon = [S(:).Lon];
   
[Lat,Lon] = polyvec({Geom.Lat},{Geom.Lon});

if outputType == "ascell"
   [Lat,Lon] = polycells(Lat,Lon);
end
