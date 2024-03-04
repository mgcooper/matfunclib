function varargout = textbox(textstr, xpct, ypct, varargin)
   %TEXTBOX Place text box at x,y percent distance from lower left figure corner
   %
   %  [h, x, y] = textbox(textstr, xpct, ypct)
   %  [h, x, y] = textbox(_, ax)
   %  [h, x, y] = textbox(_, location)
   %  [h, x, y] = textbox(_, varargin) where varargin is any name-value pair
   %  compatibile with text function
   %
   % See also: textcoords

   % note: this function is ready to be converted to this notation where instead
   % of xpct,ypct, either pass in [xpct ypct] or a char 'best' for textbp or
   % eventually if possible 'sw','nw', etc.
   % function [h, x, y] = textbox(textstr, location, varargin)

   % parse axis input
   [ax, args, ~, isfigure] = parsegraphics(varargin{:});

   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   fg = get(ax, 'Parent');
   
   % parse remaining input
   [location, args] = parseinput(textstr, xpct, ypct, mfilename, args{:});

   % if 'best' is requested, use textbp function
   if strcmpi(location, 'best') && (ischar(location) || isstring(location))
      h = textbp(textstr,args{:});
      % [x,y] = textpos(h);
      % for now just return empty x,y, but should be simple to get the x,y
      % position from the h.Position property if they're ever needed
      xtext = nan; ytext = nan;
      return
   end
   % else
   %    xpct = location(1);
   %    ypct = location(2);
   % end

   % Get the xlimits and compute the percent offset from lower left corner
   xlims = xlim;
   ylims = ylim;

   useaxpos = false;
   if iscategorical(xlims) || iscategorical(ylims)
      if iscategorical(xlims)
         try
            xlims = cat2double(xlims);
         catch
            useaxpos = true;
         end
      end
      if iscategorical(ylims)
         try
            ylims = cat2double(ylims);
         catch
            useaxpos = true;
         end
      end
   end

   if useaxpos == true
      % Set the x/y text coordinates using normalized (figure) units
      axpos = get(gca, 'Position');
      xtext = axpos(1) + xpct/100 .* axpos(3);
      ytext = axpos(2) + ypct/100 .* axpos(4);

      % Create the text object
      % h = text(ax, xtext, ytext, textstr, 'Units', 'normalized', args{:});

      % In some cases it seems necessary to use annotation
      h = annotation(fg, 'textbox',...
         [xtext ytext 0.1 0.1],...
         'String',{textstr},...
         ...'FitBoxToText', 'on', ...
         'Margin', 2, ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', ...
         ... 'LineStyle', 'none', ...
         args{:});
   else
      % Set the x/y text coordinates using data units
      xtext = xlims(:,1) + xpct/100 .* (xlims(:,2) - xlims(:,1));
      ytext = ylims(:,1) + ypct/100 .* (ylims(:,2) - ylims(:,1));

      % Create the text object
      h = text(ax, xtext, ytext, textstr, args{:});
   end

   % handle output
   nargoutchk(0, 3)
   [varargout{1:nargout}] = dealout(h, xtext, ytext);
end

%% Local Functions
function tf = validatePosition(location)
   tf = ((ischar(location) && isrow(location)) || ...
      (isstring(location) && isscalar(location) && (strlength(location) > 0))) && ...
      strncmpi(location,'best',max(strlength(location), 1));
end

%% Input Parser
function [location, unmatched] = parseinput(textstr, xpct, ypct, mfilename, varargin)

   parser = inputParser;
   parser.KeepUnmatched = true;
   parser.FunctionName = mfilename;
   parser.addRequired('textstr', @(x) ischar(x) | iscell(x) | isstring(x));
   parser.addRequired('xpct', @isnumeric);
   parser.addRequired('ypct', @isnumeric);
   parser.addOptional('location', 'user', @(x) isnumeric(x) | validatePosition(x));
   parser.parse(textstr, xpct, ypct, varargin{:});
   unmatched = unmatched2varargin(parser.Unmatched);
   location = parser.Results.location;

   % could replace xpct,ypct with location then parse for either a 1x2 numeric
   % vector or a char, see prctile function for
   % p.addOptional('location','best',@(x)isnumeric(x)||validatePosition(x));
end
