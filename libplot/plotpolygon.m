function plotpolygon(P)
%PLOTPOLYGON plot polygon data

if isa(P,'polyshape')
   arrayfun(@(n) plot(P(n)),1:numel(P));
elseif iscell(P)
   cellfun(@(x,y) plot(x,y),P(:,1),P(:,2));
elseif ismatrix(P)
   plot(P(:,1),P(:,2));
end

% For reference, if PX,PY cell arrays are passed in:
% cellfun(@plot, PX, PY);