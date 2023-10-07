function propval = getgcm(mapax,varargin)
   %GETGCM get axesm-based map property
   %
   %  propval = GETGCM('proplist') returns a list of all axesm properties
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
   
   if nargin == 1 && strcmp(mapax, 'proplist')
      propval = readlines('axesmproplist.txt');
   else
      parse(parser, mapax, varargin{:});
      prop = parser.Results.prop;

      % get the property
      propval = getm(mapax, prop);
   end
end
