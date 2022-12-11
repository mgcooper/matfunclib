function [ h,x,y ] = mytextbox( textstr,xpct,ypct,varargin)
%MYTEXTBOX places textstr at location defined by x,y coordinates in percent
%units relative to lower left corner of figure panel
%   Usage

% note: this function is ready to be converted to this notation where instead
% of xpct,ypct, either pass in [xpct ypct] or a char 'best' for textbp or
% eventually if possible 'sw','nw', etc.
% function [ h,x,y ] = mytextbox( textstr,location,varargin)

%-------------------------------------------------------------------------------
p=MipInputParser;
p.KeepUnmatched=true;
p.FunctionName='mytextbox';
p.addRequired('textstr',@(x)ischar(x)|iscell(x));
p.addRequired('xpct',@(x)isnumeric(x));
p.addRequired('ypct',@(x)isnumeric(x));
p.addOptional('location','user',@(x)isnumeric(x)||validatePosition(x));
p.addParameter('ax',gca,@(x)isaxis(x));
p.parseMagically('caller');
unmatched = unmatched2varargin(p.Unmatched);
location = p.Results.location;

% could replace xpct,ypct with location then parse for either a 1x2 numeric
% vector or a char, see prctile function for 
% p.addOptional('location','best',@(x)isnumeric(x)||validatePosition(x));
%-------------------------------------------------------------------------------

% if 'best' is requested, use textbp function
if strcmpi(location,'best')  && ischar(location) || isstring(location)
   h = textbp(textstr,unmatched{:});
   % [x,y] = textpos(h);
   % for now just return empty x,y, but should be simple to get the x,y
   % position from the h.Position property if they're ever needed
   x = nan; y = nan;
   return
end
% else
%    xpct = location(1);
%    ypct = location(2);
% end

xlims = xlim;
ylims = ylim;
xdif  = xlims(:,2) - xlims(:,1);
xjit  = xpct/100 .* xdif;
x     = xlims(:,1) + xjit;
ydif  = ylims(:,2) - ylims(:,1);
yjit  = ypct/100 .* ydif;
y     = ylims(:,1) + yjit;
h     = text(ax,x,y,textstr,unmatched{:});

% check this out! no 'end' works for subfunctions if the main one doesn't have
% it either
function tf = validatePosition(location)
tf = ((ischar(location) && isrow(location)) || ...
     (isstring(location) && isscalar(location) && (strlength(location) > 0))) && ...
     strncmpi(location,'best',max(strlength(location), 1));

