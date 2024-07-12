%% Demo MarkdownPanel

%# MarkdownPanel
% Control which displays markdown as HTML within a MATLAB control
%
% This control utilizes the [Showdown javascript library][1] to convert
% markdown into HTML and then uses MATLAB's internal HTML components to
% display this HTML.
%
% It behaves like any other graphics object within MATLAB in that all
% properties can either be set upon object construction

% mgc: this does not work
panel = MarkdownPanel('Parent', figure, 'Content', '# Hello World!');

% mgc: first create the panel (do not highlight and run w/drawnow, do them
% separately)
panel = MarkdownPanel('Parent', figure, 'Content', '# Hello World!');
% then this
drawnow
% then this: works
set(panel, 'Content', '# Hello World!')

% mgc: Doing them all at once does not work
panel = MarkdownPanel('Parent', figure, 'Content', '# Hello World!');
drawnow
set(panel, 'Content', '# Hello World!')

% mgc: drawnow actually is not necessary
panel = MarkdownPanel('Parent', figure, 'Content', '# Hello World!');
% But doing the steps sequentially is
set(panel, 'Content', '# Hello World!')

% Or after object creation using the returned handle

panel = MarkdownPanel();
panel.Parent = gcf;

% mgc: need drawnow here if sending all commands to the console
drawnow

set(panel, 'Position', [0, 0, 0.5, 0.5])

% To set the actual Markdown content, use the `Content` property. You
% can provide *either* a string, or a cell array of strings which will
% automatically create a multi-line entry

set(panel, 'Content', '#Hello World')
set(panel, 'Content', {'#Hello World', 'This is a test...'})

% You can use the `Options` property to modify options that are
% specific to how Showdown renders the markdown. By default, we use all
% of the default settings except that we enable support for tables.
%
panel.Options.tables = true;
%
% The `Options` property is simply a struct where the fieldnames are
% the option names and the value is the option value. You can modify
% this struct to adjust an option.
%
% Enable support for tasklists
panel.Options.taskslists = true;

%% Example from function documentation

content = '# Hello World!';

% This works
createMarkdownPanelDemo(content)

% note: using updated function syntax:
% createMarkdownPanel("Content", content)

% This does not
panel = MarkdownPanel('Parent', figure, 'Content', content);
set(panel, 'Content', content)


%%

% Content option 1: help text
% content = help('toolbox/plotgrace.m');

% Content option 2: actual README.md
fid = fopen("workflow/README.md");
content = fscanf(fid, '%c');
fclose(fid);

% Base case - pass the content to the demo function (works)
createMarkdownPanelDemo(content);

%% Test 1: Just pass the content

panel = MarkdownPanel('Parent', figure, 'Content', content);

% UPDATE: this is all that's needed (but must run in two steps w/o pause, and I
% needed pause >= 0.02):
pause(0.02)
set(panel, 'Content', content)

%% Test 2: Apply cleanup

content = regexprep(content, '^\s*', '');
content = regexprep(content, '\n  ', '\n');

panel = MarkdownPanel( ...
   'Parent', figure, ...
   'Content', content);

%% Test 3: Specify the style sheet

twitter = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css';

panel = MarkdownPanel( ...
   'Parent', figure, ...
   'Content', content, ...
   'StyleSheets', twitter);

% UPDATE: I added the two lines below and now it works. But drawnow actually is
% not required. Just setting the content.

% drawnow

set(panel, 'Content', content)

%% Test 4: Use uiflowcontainer

flow = uiflowcontainer('v0', 'FlowDirection', 'lefttoright');
panel = MarkdownPanel( ...
   'Parent', flow, ...
   'Content', content, ...
   'Classes', 'container');

%% Test 5: Use uiflowcontainer + stylesheet

panel = MarkdownPanel( ...
   'Parent', flow, ...
   'Content', content, ...
   'StyleSheets', twitter, ...
   'Classes', 'container');

%% Test 6: Create the figure + drawnow + uiflowcontainer

fig = figure( ...
   'Position',     [0 0 1200, 700], ...
   'Toolbar',      'none', ...
   'menubar',      'none', ...
   'NumberTitle',  'off', ...
   'Name',         'MarkdownPanel');

drawnow;

% Create two side-by-side panels
flow = uiflowcontainer('v0', 'FlowDirection', 'lefttoright');

panel = MarkdownPanel( ...
   'Parent', flow, ...
   'Content', content, ...
   'StyleSheets', twitter, ...
   'Classes', 'container');

% Also try with and without this: (doesn't work)

% Set the option to enable smooth live previews
panel.Options.smoothLivePreview = true;
   
%% Test 7: Use the java control and javacomponent

fig = figure( ...
   'Position',     [0 0 1200, 700], ...
   'Toolbar',      'none', ...
   'menubar',      'none', ...
   'NumberTitle',  'off', ...
   'Name',         'MarkdownPanel');

drawnow;

% Create two side-by-side panels
flow = uiflowcontainer('v0', 'FlowDirection', 'lefttoright');

% Create a java control because the builtin editbox doesn't
% easily return the current value
je = javax.swing.JEditorPane('text', content);
jp = javax.swing.JScrollPane(je);

originalWarnings = warning();
warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
[~, hcomp] = javacomponent(jp, [], flow);
set(hcomp, 'Position', [0 0 0.5 1])
warning(originalWarnings);

panel = MarkdownPanel( ...
   'Parent', flow, ...
   'Content', content, ...
   'StyleSheets', twitter, ...
   'Classes', 'container');

% Set the option to enable smooth live previews
panel.Options.smoothLivePreview = true;


% THIS IS THE KEY
% set(panel, 'Content', char(je.getText()));

% but this also works
set(panel, 'Content', content);

%% Now revisit the earlier simple tests

% Does not work
panel = MarkdownPanel( ...
   'Parent', figure, ...
   'Content', char(je.getText()));

% Works
panel = MarkdownPanel( ...
   'Parent', figure, ...
   'Content', content);
set(panel, 'Content', char(je.getText()));

% Works
panel = MarkdownPanel( ...
   'Parent', figure, ...
   'Content', content, ...
   'StyleSheets', twitter);
set(panel, 'Content', char(je.getText()));


% So maybe it just needs a drawnow?
