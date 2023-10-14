function tf = iscategoricalaxes(varargin)
   %ISCATEGORICALAXES
   
   % Parse graphics input
   [h, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<*ASGLU> 

   % Get handle to either the requested or a new axis.
   if isempty(h)
      ax = gca;
   elseif isfigure
      ax = gca(h);
   else
      ax = h;
   end

   % Parse optional axes flag: parseoptarg(varargin, validopts, defaultopt)
   [whichax, varargin] = parseoptarg(varargin, ...
      {'XAxis', 'YAxis', 'ZAxis'}, 'XAxis');
   
   tf = isa(get(ax, whichax), 'matlab.graphics.axis.decorator.CategoricalRuler');
end