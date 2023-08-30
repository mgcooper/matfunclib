function varargout = setPieChartColor(H, PatchOpts)
%SETPIECHARTCOLOR
% 
%  setPieChartColor(H) set the pie chart with handle H to new colors

arguments
   H (:, 1) matlab.graphics.primitive.Data
   PatchOpts.?matlab.graphics.primitive.Patch
end
opts = namedargs2cell(PatchOpts);

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

% apply the property-value pairs
cellfun(@(prop, val) set(hpatch, prop, val), ...
   fieldnames(PatchOpts), struct2cell(PatchOpts))

if nargout > 0; varargout{1} = H; end
end