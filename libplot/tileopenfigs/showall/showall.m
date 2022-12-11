function showall(layout,figs)
%SHOWALL Show all or selected figures in a grid.
%   SHOWALL by itself resizes all open figures to (hopefully) make them fit
%   on the screen all at once. A grid size is chosen automatically; there
%   may be blank spaces left.
%
%   SHOWALL(LAYOUT) lets you specify the grid size as a 2-vector, the
%   number horizontally and the number vertically.
%
%   SHOWALL(LAYOUT,FIGS) also allows you to specify a vector of figures to
%   include. Your ordering will be respected. 
%
%   If the spacing is not quite right for you, adjust the 'bufferx' and
%   'buffery' values in the code. 
%
%   Example:
%      close all, ezplot(@sin,[-pi pi])
%      figure, ezplot(@cos,[-pi pi])
%      figure, ezplot(@sinh,[-pi pi])
%      figure, ezplot(@cosh,[-pi pi])
%      showall
%
%   See also SUBPLOT.

% Copyright 2015 by Toby Driscoll (driscoll@udel.edu). 

if nargin==0
    figs = get(0,'children');
    % Sort them in order of figure number. 
    num = get(figs,'number');
    num = cat(1,num{:});
    [~,idx] =sort(num);
    figs = figs(idx);
    layout = [];
end

m = numel(figs);

% Choose a layout automatically. We brute-force the selection.
if isempty(layout)
    sz = [ 1 1; 1 2; 2 2; 2 2; 2 3; 2 3; 3 3; 3 3; 3 3; 3 4; 3 4; 3 4;
        4 4; 4 4; 4 4; 4 4; 5 4; 5 4; 5 4; 5 5 ];
    if m > 20
        error('You must supply a layout for more than 20 figures.')
    end
    layout = sz(m,:);
end
    
if any( ~ishandle(figs) ) || any( ~strcmp( get(figs,'type'), 'figure' ))
  error('Specified figure(s) do not exist')
elseif prod(layout) < m
  error('Layout does not have enough places for the figures.')
end

oldunit = get(figs,'units');
set(figs,'units','pixel','vis','off')

scrsize = get(0,'screensize');

% Annoyingly, you can't seem to find out how big the windows ACTUALLY are,
% with all their trim. These numbers are used to create padding between the
% figures. But the numbers here may be wrong for your OS and monitor size.
bufferx = 20;   
buffery = 60;

% Calculate the grid of positions.
hx = scrsize(3) / layout(2) - 2*bufferx;
hy = scrsize(4) / layout(1) - 2*buffery;
x = bufferx + (hx+2*bufferx)*(0:layout(2)-1);
y = buffery + (hy+2*buffery)*(0:layout(1)-1);
[X,Y] = meshgrid(round(x),round(y));

% This is needed to go left->right, then top->bottom.
X = flipud(X)';  Y = flipud(Y)';

% Set the new positions.
for j = 1:m
    set(figs(j),'pos',[X(j) Y(j) hx hy])
    figure(figs(j))
end

% Show all work.
set(figs,{'units'},oldunit,'vis','on')

end