function [ h,x,y ] = mytextbox( textstr,xpct,ypct,varargin)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% % check if an axis handle is provided (credit to Kelley Kearney, function
% % 'boundedline', for this argument check)
% isax = cellfun(@(x) isscalar(x) && ishandle(x) &&                       ...
%             strcmp('axes', get(x,'type')), varargin);
% if any(isax)
%     ax = varargin{isax};
%     varargin = varargin(~isax);
% else
%     % get handle for existing figure and/or create a new axis object
%     ax = gca;
% end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p=MipInputParser;
   p.KeepUnmatched=true;
   p.FunctionName='mytextbox';
   p.addRequired('textstr',@(x)ischar(x));
   p.addRequired('xpct',@(x)isnumeric(x));
   p.addRequired('ypct',@(x)isnumeric(x));
   p.addParameter('ax',gca,@(x)isaxis(x));
   p.parseMagically('caller');
   unmatched = unmatched2varargin(p.Unmatched);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   


xlims   =   get(ax,'xlim');
ylims   =   get(ax,'ylim');

xdif    =   xlims(:,2) - xlims(:,1);

xoffset =   xpct/100 .* xdif;

x       =   xlims(:,1) + xoffset;

ydif    =   ylims(:,2) - ylims(:,1);

yoffset =   ypct/100 .* ydif;

y       =   ylims(:,1) + yoffset;

h       =   text(ax,x,y,textstr,unmatched{:});




end

