% test_parsegraphics

%%

% this will fail: parsegraphics("Parent", gcf) b

[ax,args,nargs,isfigure] = parsegraphics(varargin{:});
[ax,args,nargs] = axescheck(varargin{:});

plot(1:10, 1:10, '-o', "Parent", ax)
plot(ax, 1:10, 1:10, '-o')