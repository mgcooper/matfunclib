% i need a tutorial on colormaps

% one way to 'hack' a colormap for a surface / patch type plot is to loop over
% all elements and use the face mapping variable, e.g. elevation, as the 'C'
% value in fill, 

% say we have x,y,elev, where each row of x,y is a list of vertices
[elev,idx] = sort(Elev);
x = x(idx,:);
y = y(idx,:);

macfig; hold on;
for n = 1:numel(x)
   fill(x(n,:),y(n,:),elev(n));
end
axis image; hold off; colorbar;

% say we have a structure (e.g. shapefile) where each row is a feature and like
% above has x,y vertices, but they have different numbers of vertices so the
% pre-indexing isn't as simple:
[elev,idx] = sort(Elev);

macfig; hold on;
for n = 1:numel(x)
   fill(S(idx(n)).x,S(idx(n)).y,elev(n));
end
axis image; hold off; colorbar;



% -----------------------------------
% this is wrong because the elements of FaceColor aren't mapped onto the data

FaceColor = fake_parula(numel(S));
hold on;
for n = 1:numel(Mesh)
   fill(S(n).Lon,S(n).Lat,FaceColor(n,:));
end

% to fix that, we need to convert the data into indices on FaceColor, which
% should be trivial using interp1

x  = 1:numel(S);
xq =    


x = [S.Elevation]; x = x - min(x(x<0));
indices = 0:255;
xref = linspace(min(x),max(x),length(indices));
indexed_x = interp1(xref,indices,'nearest');
% then you can map to whatever colormap you want, e.g.
graymap = gray(length(indices));
xcolors = graymap(indexed_x,:);












