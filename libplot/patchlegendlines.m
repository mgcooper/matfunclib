function p = patchlegendlines(legobj)
%PATCHLEGENDLINES add lines to patch objects in legend using pre-2014 legobj
%created by call to legend: [leghandle,legobj] = legend(__)
% 
% p = patchlegendlines(legobj)
% 
% See also: 

if nargin < 1
   legobj = getlegobj(gcf);
   if isempty(legobj)
      error('this function only works if legend was created using syntax [leghandle,legobj] = legend(__)')
   end
end

p = findall(legobj,'Type','Patch');
dc = get(gca,'ColorOrder');

for n = 1:numel(p)
   p(n).FaceAlpha = 0.25;
   % p(n).LineWidth = 2;   
   x = get( p(n),'xdata');
   y = get( p(n),'ydata');
   x = [x; x(1); x(end)];
   y = [y; mean(y); mean(y)];
   % c = get(h1(n),'faceVertexCData');
   c = [ repmat([1, 1, 1],[4 1]); repmat(dc(n,:),[2,1]) ]; % dc(1,:)
   ff = [1 2 3 4; 5 6 6 6];
   set( p(n),'vertices',[x y],'faces',ff,'faceVertexCData', c,'edgecolor','flat')
end
