function varargout = inset(mainFigure, insetFigure, varargin)
   %INSET combines two open figures and makes one an inset of the other
   %
   %    h = inset(mainFigure, insetFigure)
   %    [mainAxes, insetAxes] = inset(mainFigure, insetFigure)
   %    [h, mainFigure, insetFigure] = inset(mainFigure, insetFigure)
   %    h = inset(mainFigure, insetFigure, sizefactor, location)
   %    h = inset(mainFigure, insetFigure, location=location)
   %    h = inset(mainFigure, insetFigure, multiplier=multiplier)
   %    h = inset(mainFigure, insetFigure, WENSmultiplier=WENSmultiplier)
   %    h = inset(mainFigure, insetFigure, sizefactor=sizefactor)
   %    h = inset(mainFigure, insetFigure, copylegend=copylegend)
   %
   %  Description
   %
   %    H = INSET(MAINFIGURE, INSETFIGURE) places a figure inside another figure
   %    (main and inset) from 2 existing figures.
   %
   %  Inputs
   %
   %    SIZEFACTOR - the fraction of inset-figure size, default value is 0.35
   %
   %  Outputs
   %
   %  With one output, H is a struct containing the new figure and copied axes.
   %  With two outputs, the first copied main axes and inset axes are returned.
   %  With three outputs, H is returned along with the original figure handles.
   %
   %  based on: inset.m, by Moshe Lindner, August 2010 (C).
   %
   % See also:

   [legacyArgs, varargin] = parselegacyinputs(varargin);

   parser = inputParser;
   parser.FunctionName = mfilename;

   validlocs = {'north','south','east','west','ne','se','nw','sw'};
   validoption = @(x)any(validatestring(x,validlocs));

   parser.addRequired('mainFigure', @(x) isgraphics(x) && isscalar(x));
   parser.addRequired('insetFigure', @(x) isgraphics(x) && isscalar(x));
   parser.addParameter('sizefactor', 0.35, @isnumeric);
   parser.addParameter('location', 'nw', validoption);
   parser.addParameter('multiplier', 1, @isnumeric);
   parser.addParameter('WENSmultiplier', [1,1,1,1], @(x) isnumeric(x) && numel(x) == 4);
   parser.addParameter('copylegend', false, @islogical)
   parser.parse(mainFigure, insetFigure, legacyArgs{:}, varargin{:});

   mainFigure = ancestor(handle(mainFigure), 'figure');
   insetFigure = ancestor(handle(insetFigure), 'figure');

   size        = parser.Results.sizefactor;
   location    = parser.Results.location;
   multiplier  = parser.Results.multiplier;
   WENS        = parser.Results.WENSmultiplier(:).';
   copylegend  = parser.Results.copylegend;

   % NOTE see export_fig function copyfig, should fix the issues where not all
   % figure props are copied over with copyobj

   size = size * multiplier;

   % create a newFig based on the mainFigure and copy over children
   newFig = figure( ...
      'Position', mainFigure.Position, ...
      'Color', mainFigure.Color, ...
      'Colormap', mainFigure.Colormap);

   mainFigAxes = flip(findobj(mainFigure,'Type','axes'));
   mainLegend = findobj(mainFigure,'Type','Legend');
   mainText = findall(mainFigure,'Type','Annotation');
   mainCbar = findall(mainFigure,'Type','ColorBar');

   if isempty(mainFigAxes)
      error('inset:NoMainAxes', 'Main figure must contain at least one axes.');
   end

   % Copy all objects (copyobj requires all objects are copied at once)
   objectsToCopy = [mainFigAxes; mainLegend; mainText; mainCbar];
   newMainAxes = copyobj(objectsToCopy, newFig);

   % Cycle over them and set the font size property. Add additional custom
   % fixes to default copyobj behavior as needed. See note below about font
   % sizes not copying over.
   for n = 1:numel(objectsToCopy)
      try
         newMainAxes(n).FontSize = objectsToCopy(n).FontSize;
      catch
      end
   end

   % allchild or findall could be used instead of the ones above to get them all
   % at once, but I am not certain what the difference is b/w allchild and
   % findall and also they return lots of stuff I don't think we want to pass to
   % copyobj, so for now, I add items to the list above as use-cases pop up.
   %
   % allchilds = allchild(mainFigure);
   % allchilds = findall(mainFigure);
   % % for example, these do not work:
   % newMainAxes = copyobj(allchilds,newFig);
   % for n = 1:numel(allchilds)
   %    newMainAxes = copyobj(allchilds(n),newFig);
   % end

   for n = 1:numel(mainFigAxes)
      newMainAxes(n).Position = mainFigAxes(n).Position;
   end

   % set(newMainAxes,'Position', get(mainFigAxes,'Position'))

   % this copies the inset onto newFig. It doesn't copy the legend or
   % annotation from the inset. Update 16 Nov 2023 - added flip. If multiple
   % axes are found (e.g. w/tiledlayout), I think findobj returns them in the
   % "opposite" order they were plotted in, i.e., from the top down. Not sure
   % this will work in general.
   insetFigAxes = flip(findobj(insetFigure, 'Type', 'axes'));
   if isempty(insetFigAxes)
      error('inset:NoInsetAxes', 'Inset figure must contain at least one axes.');
   end

   if copylegend
      % The legend must be copied with its axes, but I need a way to resize it,
      % and I am not sure how the "flip" operation on insetFigAxes affects it
      insetLegend = findobj(insetFigure, 'Type', 'Legend');
      oldInsetObj = [insetLegend; insetFigAxes];
   else
      oldInsetObj = insetFigAxes;
   end

   newInsetAxes = copyobj(oldInsetObj, newFig);


   for n = 1:numel(newInsetAxes)
      newInsetAxes(n).Position = oldInsetObj(n).Position;

      % This does not include the legend because it apparently must be ordered
      % first in the oldInsetObj array, and that messes up the Title String
      % portion of the loop below. If a situation arises where a legend with a
      % title needs to be copied over, this will need to be adjusted
      if isa(newInsetAxes(n), 'matlab.graphics.illustration.Legend')
         newInsetAxes(n).FontSize = oldInsetObj(n).FontSize;
         continue
      end

      % FontSize does not copy over correctly, see:
      % https://www.mathworks.com/matlabcentral/answers/813085-why-does-copyobj
      % -fail-to-copy-over-title-fontsizes-and-also-colorbars-and-colormaps
      if ~isempty(newInsetAxes(n).Title.String)
         newInsetAxes(n).Title.String = '';              % clear copied title
         copyobj(oldInsetObj(n).Title, newInsetAxes(n)) % copy original one
      end
   end


   pos = get(mainFigAxes, 'Position');

   if iscell(pos) && numel(pos)>1
      pos = pos{1};
   end

   % 1 is left/right, 2 is up/down, 3 is

   xWest    = WENS(1) * (pos(1) + 0.3 * (pos(3) - size)); % was 0.9
   xEast    = WENS(2) * (pos(1) + pos(3) - size);
   yNorth   = WENS(3) * (pos(2) + pos(4) - size);  % was 0.9, 0.98
   ySouth   = WENS(4) * (-2 * pos(2) + pos(4) - size);   % was 1.5

   switch location
      case 'ne'
         newPos = [xEast yNorth size size];
      case 'nw'
         newPos = [xWest yNorth size size];
      case 'se'
         newPos = [xEast ySouth size size];
      case 'sw'
         newPos = [xWest ySouth size size];
   end

   % If the legend is not copied over, these settings should work. When I
   % tried copying a legend, I needed to move the axes over to the left by
   % adjusting the third index of newPos, rather than the first. See commented
   % out loop below this one for that purpose.
   offset = 0;
   for n = 1:numel(newInsetAxes)
      % Original method set all to same new position:
      % newInsetAxes(n).Position = newPos;

      if isa(newInsetAxes(n), 'matlab.graphics.illustration.Legend')

         % If a legend object is encountered, the (n-1) multiplier won't work as
         % intended - it creates a blank space for the legend (which might
         % actually be desired in some cases, but not in the case I tested), so
         % create an offset to account for that
         offset = offset + 1;

         % Continue to reposition all non-legend objects before the legend
         continue

      elseif isa(newInsetAxes(n),'matlab.graphics.axis.Axes')
         % This sets the x-position so if newInsetAxes is a subplot, they don't
         % get copied on top of each other. Not sure if this will work in
         % general. The 1.1 adds a bit of space between each axes.
         newPosAdjusted = newPos;
         newPosAdjusted(1) = newPos(1) + (n-1-offset) * newPos(3) * 1.1;
         newInsetAxes(n).Position = newPosAdjusted;
      end
   end

   % Reposition legend objects
   for n = 1:numel(newInsetAxes)

      if isa(newInsetAxes(n), 'matlab.graphics.illustration.Legend')

         % The axes method does not work for the legend. In testing copylegend,
         % I was able to drag the legend to the desired position, unlike the
         % axes. Thus I only needed to change the legend font size to achieve
         % the right position/size.

         % Apply custom setting using guess and check until an automated method
         % newPos = oldInsetObj(n).Position;
         % newPosAdjusted = newPos;
         % newPosAdjusted(1) = newPos(1) + (n-1) * newPos(3) * 1.1;
         % newInsetAxes(n).Position = newPosAdjusted;

         % Something I must have experimented with:
         % newInsetAxes(n).Position = oldInsetObj(n).Position./10;
         
         % Another edge case - I had to make the line icons narrower to fit
         % newInsetAxes(n).IconColumnWidth = 20;
      end
   end

   % When copylegend is true, it was necessary to manually readjust the axes
   % after dragging the legend to the desired location
   for n = 1:numel(newInsetAxes)
      if isa(newInsetAxes(n), 'matlab.graphics.illustration.Legend')
         continue
      else
         % I had to manually adjust here
         % newPosAdjusted = newPos;
         % newPosAdjusted(2) = newInsetAxes(n).Position(2) * 1.01;
         % newInsetAxes(n).Position = newPosAdjusted;

         % These are just the settings that worked for the pie chart figure
         % newInsetAxes(n).Position(2) = 0.58;
         % newInsetAxes(n).Position(1) = newInsetAxes(n).Position(1) * 1.2;
      end
   end

   h.figure    = newFig;
   h.mainFigure = mainFigure;
   h.insetFigure = insetFigure;
   h.mainAxes  = newMainAxes(1:numel(mainFigAxes));
   h.insetAxes = newInsetAxes(arrayfun(@(obj) isa(obj, 'matlab.graphics.axis.Axes'), newInsetAxes));
   h.mainObjects = newMainAxes;
   h.insetObjects = newInsetAxes;

   set(newFig, 'CurrentAxes', h.mainAxes(1));

   % original xWest:
   % .7*pos(1)+0.3*(pos(3)-insetSize)

   % original yNorth:
   % .3*pos(2)+ax(4)-inset_size

   % original xEast:
   % .8*pos(1)+pos(3)-insetSize

   % original ySouth:
   % -2*pos(2)+pos(4)-insetSize

   % to move yNorth up a bit:
   % .65*pos(2)+pos(4)-insetSize
   switch nargout
      case 0
      case 1
         varargout{1} = h;
      case 2
         varargout{1} = h.mainAxes(1);
         varargout{2} = h.insetAxes(1);
      otherwise
         varargout{1} = h;
         varargout{2} = mainFigure;
         varargout{3} = insetFigure;
   end
end

function [legacyArgs, args] = parselegacyinputs(args)
   legacyArgs = {};

   if ~isempty(args) && isnumeric(args{1}) && isscalar(args{1})
      legacyArgs = [legacyArgs, {'sizefactor', args{1}}]; %#ok<AGROW>
      args = args(2:end);
   end

   if ~isempty(args) && ((ischar(args{1}) && isrow(args{1})) || ...
         (isstring(args{1}) && isscalar(args{1})))
      loc = lower(string(args{1}));
      validlocs = ["north","south","east","west","ne","se","nw","sw"];
      if ismember(loc, validlocs)
         legacyArgs = [legacyArgs, {'location', char(loc)}]; %#ok<AGROW>
         args = args(2:end);
      end
   end
end
