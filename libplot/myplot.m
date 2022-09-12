function [p,ax] = myplot(x,y,varargin)
%MYPLOT wrapper for plot
%   Detailed explanation goes here

    p                   =   plot(x,y,varargin{:}); 
    ax                  =   gca;
    ax.LineWidth        =   1.5;
    ax.TickDir          =   'Out';
    ax.Box              =   'off';
    
%   Some plots look much better with offsetAxes and minor tick on, but once
%   offsetAxes screws up anything that comes after, so need to set it
%   within the scripts

%     ax.XAxis.MinorTick  =   'on';
%     ax.YAxis.MinorTick  =   'on';
%     offsetAxes(ax);
    
%   tickformat is not always desired but could be added
%     if box_on == 1
%         tickformat()
%     end
end

