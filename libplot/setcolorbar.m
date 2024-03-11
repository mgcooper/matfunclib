function varargout = setcolorbar(C, props, opts)
   %SETCOLORBAR set colorbar properties
   %
   % [C, climits] = setcolorbar(C)
   % [C, climits] = setcolorbar(C, Name, Value)
   %
   % See also: getcolorbar

   arguments
      C (:,1) = getcolorbar
      props.?matlab.graphics.illustration.ColorBar
      opts.Label string = string.empty()
      opts.Title string = string.empty()
      opts.AutoColorLimits (1,1) logical = false % Add this line
   end

   % apply the property-value pairs
   cellfun(@(p, v) set(C, p, v), fieldnames(props), struct2cell(props))

   % Get color limits based on all data associated with the colorbars
   try
      climits = cell2mat(get(C, 'Limits')); % multiple colorbar
   catch
      climits = get(C, 'Limits'); % one colorbar
   end
   climits = [min(climits(:,1)), max(climits(:,2))];

   % Set color limits
   if opts.AutoColorLimits
      for n = 1:numel(C)
         C(n).Limits = climits;
      end
      % look for objects with cdata
      % scatterobj = findobj(gcf, 'Type', 'Scatter');
      % set(scatterobj, 'CData') problem is we don't want to reset the CData, we
      % want it mapped to the colorbar limits
   end

   % Set custom opts
   for n = 1:numel(C)
      if ~isempty(opts.Label)
         set(get(C(n), 'Label'), 'String', opts.Label(n))
      end
      if ~isempty(opts.Title)
         set(get(C(n), 'Title'), 'String', opts.Title(n))
      end
   end

   % send back the legend object if requested
   [varargout{1:nargout}] = dealout(C, climits);
end

% function c = setcolorbar( width,height,location,title,label )
% %SETCOLORBAR add a colorbar or set properties of a colorbar. adjust width by
% %delta percent
%
% % % this was mycbar.m. It just called this function, which was previously
% % mycolorbar.m but I renamed it setcolorbar.m
% % function c = mycbar( width,height,location,title,label )
% % narginchk(3,5)
% % switch nargin
% %   case 3
% %       c = mycolorbar( width,height,location);
% %   case 4
% %       c = mycolorbar( width,height,location,title);
% %   case 5
% %       c = mycolorbar( width,height,location,title,label);
% % end
%
% % % this was setcolorbar.m
% % function c = setcolorbar(c,varargin)
% % switch varargin{1}
% %    case 'Title'
% %       c.Title.String  = varargin{2};
% %    case 'Location'
% %       c.Location      = varargin{2};
% % end
%
%
% narginchk(3,5)
%
% if nargin<4
%     title = '';
%     label = '';
% elseif nargin==4
%     label = '';
% end
%
% switch location
%     case {'southout','southoutside'}
%         location = 'southoutside';
%     case {'northout','northoutside'}
%         location = 'northoutside';
%     case {'eastout','eastoutside'}
%         location = 'eastoutside';
%     case {'westout','westoutside'}
%         location = 'westoutside';
% end
%
% % this would be simpler but I could not get it to work
% % if contains(location,'out')
% %     location = replace(location,'out','outside');
% % end
%
% ax      = gca;
% c       = colorbar('Location',location); pause(.01)
% axpos   = ax.Position;
% cpos    = get(c,'Position');
% switch location
%     case {'east','west','eastoutside','westoutside'}
% %         cpos(2) = cpos(2)-(1-height)*cpos(2); % doesn't work for subplots
%         cpos(3) = width*cpos(3);
%         cpos(4) = height*cpos(4);
%     case {'north','south','northoutside','southoutside'}
%         cpos(1) = cpos(1)+(1-width)*cpos(1);
%         cpos(3) = width*cpos(3);
%         cpos(4) = height*cpos(4);
% end
% set(c,'Position',cpos);
% set(gca,'Position',axpos);
%
% % new, add title
% ct          = get(c,'title');
% ct.String   = title;
% ct.Units    = 'normalized';
%
% % not sure about this ... might not be worth the trouble
% switch location
%     case {'east','west','eastoutside','westoutside'}
%
%     case {'north','south','northoutside','southoutside'}
%         ct.Position(1) = 1.05;
%         ct.Position(2) = c.Position(2);
% end
%
% c.Label.String = label;
%
