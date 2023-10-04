function h = formaterrorbar(h,varargin)
   %FORMATERRORBAR Apply formatting to error bar.
   %
   %  h = formaterrorbar(h, varargin);
   %
   % See also: formatplotmarkers, figformat

   % parse inputs
   [opts] = parseinputs(h, mfilename, varargin{:});
   
   if ischar(opts.color)
      color = rgb(opts.color);
   end

   if sum(opts.facecolor) ~= sum(opts.color) && sum(opts.facecolor) ~= sum([.7 .7 .7])
      color = opts.facecolor;
   end

   % apply the formatting
   set(h                                          , ...
      'LineStyle'         , opts.linestyle        , ...
      'Color'             , opts.color            , ...
      'LineWidth'         , opts.linewidth        , ...
      'Marker'            , opts.marker           , ...
      'MarkerSize'        , opts.markersize       , ...
      'MarkerEdgeColor'   , opts.edgecolor        , ...
      'MarkerFaceColor'   , opts.facecolor        , ...
      'CapSize'           , opts.capsize          );


   % note: in order to get the below to work, the line and the face color need
   % to be the same, but i think theres a way to convert the rbg triplet to
   % the color code used in h.Line.ColorData at the link below in which case i
   % could add checks for the case where i pass in facecolor but not color

   % https://www.mathworks.com/matlabcentral/answers/473325-how-to-make-errorbar-transparent

   % set transparency of the bars
   set([h.Bar, h.Line], 'ColorType', 'truecoloralpha',   ...
      'ColorData', [h.Line.ColorData(1:3); 255*opts.alpha])

   % set transparency of marker faces
   set(h.MarkerHandle, 'FaceColorType', 'truecoloralpha',   ...
      'FaceColorData', [h.Line.ColorData(1:3); 255*opts.alpha])

   % set transparency of the caps (didn't confirm this
   set(h.CapH, 'EdgeColorType', 'truecoloralpha', ...
      'EdgeColorData', [h.Cap.EdgeColorData(1:3); 255*0.5])

   % the end caps on the errorbar were still solid, but I was able to make them
   % transparent with other undocumented properties in the errorbar object. In
   % case someone else may be trying to do the same thing:
   % The hidden properties h.CapH and h.MarkerHandle can be adjusted the same
   % way as h.Line and h.Bar as above, but use FaceColorData & FaceColorType
   % and EdgeColorData & EdgeColorType properties in place of ColorData &
   % ColorType (or can be set to 'visible','off').

end

function opts = parseinputs(mfilename, varargin)
   
   parser = inputParser;
   parser.CaseSensitive = false;
   parser.FunctionName = mfilename;

   parser.addParameter('linestyle',   '-',        @ischar);
   parser.addParameter('marker',      'o',        @ischar);
   parser.addParameter('linewidth',   1.5,        @ischar);
   parser.addParameter('color',       [.3 .3 .3], @(x)isnumeric(x)||ischar(x));
   parser.addParameter('edgecolor',   [.2 .2 .2], @(x)isnumeric(x)||ischar(x));
   parser.addParameter('facecolor',   [.7 .7 .7], @(x)isnumeric(x)||ischar(x));
   parser.addParameter('capsize',     0,          @isnumeric);
   parser.addParameter('markersize',  8,          @isnumeric);
   parser.addParameter('alpha',       0.5,        @isnumeric);
   parser.parse(varargin{:});
   opts = parser.Results;
end
