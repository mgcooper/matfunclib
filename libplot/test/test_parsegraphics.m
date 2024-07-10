% test_parsegraphics
clearvars
close all
clc

withwarnoff('parsegraphics:MultipleGraphicsFound');

% Prepare test data
test_figure = figure('Visible', 'off');
test_axes = gca;

% Perform image tests if the toolbox is available
do_image_tests = true;
try
   test_image = image('Visible', 'off');
   test_image_axes = imgca;
catch e
   do_image_tests = false;
end

% plot(1:10, 1:10, '-o', "Parent", ax)
% plot(ax, 1:10, 1:10, '-o')


% not sure why I had this note here, but it was from before I refactored
% parsegraphics to find graphics in any arbitrary location rather than the first
% argument.
% this will fail: parsegraphics("Parent", gcf) b

% For reference, if needed for comparison
% [ax, outargs, nargs] = axescheck(inargs{:});

%% test axes first input

inargs = {test_axes, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});
% [ax,args,nargs] = axescheck(varargin{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test figure first input

inargs = {test_figure, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});
% [ax,args,nargs] = axescheck(varargin{:});

assert(isfig(ax))
assert(nargs == 1)
assert(wasfigure == true)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test axes second input

inargs = {"dummy", test_axes};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});
% [ax,args,nargs] = axescheck(varargin{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test figure second input

inargs = {"dummy", test_figure};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});
% [ax,args,nargs] = axescheck(varargin{:});

assert(isfig(ax))
assert(nargs == 1)
assert(wasfigure == true)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test Parent, Axes first input

inargs = {"Parent", test_axes, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test Parent, Axes second input

inargs = {"dummy", "Parent", test_axes};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test figure first, Parent, axes second input

inargs = {test_figure, "Parent", test_axes, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isfig(ax))
assert(nargs == 1)
assert(wasfigure == true)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test axes first, Parent, axes second input
inargs = {test_axes, "Parent", test_axes, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test image first input

inargs = {test_image, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == true)
assert(strcmp("dummy", outargs{:}))

%% test image second input

inargs = {"dummy", test_image};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == true)
assert(strcmp("dummy", outargs{:}))

%% test image axes first input

% note - an "image axes" is just an axes, so wasimage should be false

inargs = {test_image_axes, "dummy"};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))

%% test image axes second input

% note - an "image axes" is just an axes, so wasimage should be false

inargs = {"dummy", test_image_axes};
[ax, outargs, nargs, wasfigure, wasimage] = parsegraphics(inargs{:});

assert(isaxis(ax))
assert(nargs == 1)
assert(wasfigure == false)
assert(wasimage == false)
assert(strcmp("dummy", outargs{:}))
