function [h,ax] = logplot(x,y,dim,varargin)
%LOGPLOT plots data x vs y with 'dim' axis set to log
%   Detailed explanation goes here

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


