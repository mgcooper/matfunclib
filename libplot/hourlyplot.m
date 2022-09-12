function [ h ] = hourlyplot( data,yri,moi,dayi,hri,mni,yrf,mof,dayf,hrf,mnf,...
                        dt,dx,x1,dateformat,rm_leap,varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% dt is the timestep of the actual data, in hours
% dx is the timestep you want labeled on the figure
% x1 is the first timestep you want labeled in units of hours
% dateformat is standard matlab dateformat
%

t       =   timebuilder(yri,moi,dayi,hri,mni,yrf,mof,dayf,hrf,dayf,dt);
t2      =   time_builder(yri,moi,dayi,hri,mni,yrf,mof,dayf,hrf,dayf,dx);

if rm_leap == 1
    t   =   rmleapinds(t,t);
    t2  =   rmleapinds(t2,t2);
end

[si,ei] =   dateInds(yri,moi,dayi,hri,yrf,mof,dayf,hrf,t);
xdates  =   t(:,7); 
xticks  =   t2(:,7) + x1;
xlabels =   datestr(xticks,dateformat);

h       =   plot(xdates,data,varargin{:});

set(gca    ,      'xtick'         ,   xticks                      , ...
                'xticklabel'    ,   xlabels                      , ...
                'xlim'          ,   [xticks(1) xticks(end)]     );


end

% timebuilder(1989,10,1,1990,9,30,[])
