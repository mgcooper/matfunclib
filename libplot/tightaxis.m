function tightaxis(ax, varargin)
   %TIGHTAXIS Set the axis of your choice to be tight
   %
   %  tightaxis(ax)
   %  tightaxis(ax, 'x')
   %  tightaxis(ax, 'y')
   %
   % See also: 
   
   if numel(ax) > 1
      for n = 1:numel(ax)
         setoneaxistight(ax(n), varargin{:})
      end
   else
      setoneaxistight(ax, varargin{:})
   end
end

function setoneaxistight(ax, varargin)

   if any(ismember(varargin,'x'))
      ax.XLim = tightxlimits(ax);
   end

   if any(ismember(varargin,'y'))
      ax.YLim = tightylimits(ax);
   end
end

function limits = tightxlimits(axobj)

   children = axobj.Children;
   limits = [Inf -Inf];

   for n = 1:numel(children)
      try
         limits(1) = min(limits(1), min(children(n).XData));
         limits(2) = max(limits(2), max(children(n).XData));
      catch
      end
   end
end

function limits = tightylimits(axobj)

   children = axobj.Children;
   limits = [Inf -Inf];

   for n = 1:numel(children)
      try
         limits(1) = min(limits(1), min(children(n).YData));
         limits(2) = max(limits(2), max(children(n).YData));
      catch
      end
   end
end
