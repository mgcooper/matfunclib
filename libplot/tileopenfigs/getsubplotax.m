function ax = getsubplotax
h=get(gcf,'children');
ax = findall(h,'Type','Axes');