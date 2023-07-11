function varargout = setPieChartColor(H)
%SETPIECHARTCOLOR
% 
%  setPieChartColor(H) set the pie chart with handle H to new colors

hpatch = findobj(H, 'Type', 'Patch');
Npatch = length(hpatch);
colors = colororder;
Ncolor = size(colors,1);

% Create an index from 1:Nobjects
idx = repmat(1:Ncolor,1,ceil(Npatch/Ncolor));
idx = idx(1:Npatch);

for n=1:Npatch
   hpatch(n).FaceColor = colors(idx(n),:);
end

if nargout > 0; varargout{1} = H; end
end