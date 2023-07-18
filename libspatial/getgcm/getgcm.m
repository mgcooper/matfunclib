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

% parse inputs
persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.KeepUnmatched = true;
   parser.addRequired('mapax', @isaxis);
   parser.addOptional('prop', 'MapProjection', @ischarlike);
end
parse(parser, mapax, varargin{:});
prop = parser.Results.prop;

%% main
propval = getm(mapax,prop);







