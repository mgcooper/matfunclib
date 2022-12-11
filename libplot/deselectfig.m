function deselectfig(varargin)
% DESELECTFIG deselects the current figure
% See also deselectall
if nargin == 0
   obj = gcf;
else
   obj = varargin{:};
end
set(obj,'SelectionHighlight','off')

% this will delete the data tips that won't go away, but not sure about
% unintended concequences
delete(findall(obj,'Type','hggroup'));

% https://www.mathworks.com/matlabcentral/answers/91440-how-do-i-remove-automatic-selection-highlighting-of-the-figure-axes-when-i-use-the-plotedit-function