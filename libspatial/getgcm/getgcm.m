function propval = getgcm(mapax,varargin)
%GETGCM get axesm-based map property
% 
%  propval = GETGCM(mapax) returns a list of all axesm-based map properties
%  propval = GETGCM(mapax,requestedprop) returns the value of requestedprop
% 
% Example
%     mapax = worldmap('North Pole');
%     latlims = getgcm(mapax,'MapLatLimit')
%     mapproj = getgcm(mapax,'MapProjection')
% 
% Matt Cooper, 19-Jan-2023, https://github.com/mgcooper
% 
% See also 

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.KeepUnmatched   = true;

p.addRequired( 'mapax',                   @(x)isaxis(x)     );
p.addOptional( 'prop',  'MapProjection',  @(x)ischarlike(x) );

p.parseMagically('caller');
%-------------------------------------------------------------------------------

propval = getm(mapax,prop);










