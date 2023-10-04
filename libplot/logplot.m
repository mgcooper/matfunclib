function [h,ax] = logplot(x,y,dim,varargin)
   %LOGPLOT Plot x vs y with 'dim' axis set to log
   %
   %  [h, ax] = logplot(x,y,dim)
   %
   % Inputs
   % x - x-data
   % y - y-data
   % dim - which dimension to log. Options are 'x', 'y', 'xy'
   %
   % See also:

   if strcmp(dim,'x')
      h = plot(x,y,varargin{:}); ax = gca;
      set(ax,'XScale','log');
   elseif strcmp(dim,'y')
      h = plot(x,y,varargin{:}); ax = gca;
      set(ax,'YScale','log');
   elseif strcmp(dim,'xy')
      h = plot(x,y,varargin{:}); ax = gca;
      set(ax,'YScale','log','XScale','log');
   else
      warning('Specify dimension ''x'' ''y'' or ''xy''');
   end
end
