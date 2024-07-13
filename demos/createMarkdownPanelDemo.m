function panel = createMarkdownPanelDemo(content)
   % demo - Demonstrate how to create/use the MarkdownPanel object
   %
   %   This demo creates a simple markdown editor/preview window
   %   that showcases how to set the content of the markdown
   %   panel. To do this, it simply shows the help text for the
   %   MarkdownPanel in both the editor and preview.
   %
   %   It also demonstrates the use of stylesheets (in this case
   %   Twitter Bootstrap)
   %
   % USAGE:
   %   panel = MarkdownPanel.demo()

   fig = figure( ...
      'Position',     [0 0 1200, 700], ...
      'Toolbar',      'none', ...
      'menubar',      'none', ...
      'NumberTitle',  'off', ...
      'Name',         'MarkdownPanel');

   movegui(fig, 'center');
   drawnow;

   % Create two side-by-side panels
   flow = uiflowcontainer('v0', 'FlowDirection', 'lefttoright');

   % Grab the help section and do a little cleanup
   if nargin < 1
      content = help(mfilename('fullpath'));
   end
   content = regexprep(content, '^\s*', '');
   content = regexprep(content, '\n  ', '\n');

   % Create a java control because the builtin editbox doesn't
   % easily return the current value
   je = javax.swing.JEditorPane('text', content);
   jp = javax.swing.JScrollPane(je);

   originalWarnings = warning();
   warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
   [~, hcomp] = javacomponent(jp, [], flow);
   set(hcomp, 'Position', [0 0 0.5 1])
   warning(originalWarnings);

   % Construct the MarkdownPanel object
   twitter = 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css';
   panel = MarkdownPanel( ...
      'Content',      content, ...
      'Parent',       flow, ...
      'StyleSheets',  twitter, ...
      'Classes',      'container');

   % Set the option to enable smooth live previews
   panel.Options.smoothLivePreview = true;

   % Setup a timer to refresh the MarkdownPanel periodically
   timerFcn = @(s,e)set(panel, 'Content', char(je.getText()));
   htimer = timer( ...
      'Period',        1, ...
      'BusyMode',      'drop', ...
      'TimerFcn',      timerFcn, ...
      'ExecutionMode', 'fixedRate');

   % Destroy the timer when the panel is destroyed
   function stopAndDeleteTimer()
      stop(htimer);
      delete(htimer);
   end

   L = addlistener(panel, 'ObjectBeingDestroyed', @(s,e)stopAndDeleteTimer());
   setappdata(fig, 'Timer', L);

   % Start the refresh timer
   start(htimer)
end
