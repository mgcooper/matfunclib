function varargout = createMarkdownPanel(kwargs)
   %createMarkdownPanel Create a MarkdownPanel object
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

   arguments
      kwargs.Parent = []
      kwargs.Content {mustBeFile} = help(mfilename('fullpath'))
      kwargs.StyleSheet = 'twitter'
      kwargs.ContainerType = 'none'
   end

   assert(activate('MarkdownPanel', 'silent', true))

   %% Parse the kwargs

   % Parent
   if isempty(kwargs.Parent)
      fig = figure( ...
         'Position',     [0 0 1200, 700], ...
         'Toolbar',      'none', ...
         'menubar',      'none', ...
         'NumberTitle',  'off', ...
         'Name',         'MarkdownPanel');
   else
      fig = kwargs.Parent;
   end

   % This creates a distracting "flash" on screen
   % movegui(fig, 'center');
   % drawnow;

   % Content
   content = kwargs.Content;

   if isfile(content)
      fid = fopen(content, "rt");
      content = fscanf(fid, '%c');
      fclose(fid);
   end

   % StyleSheet
   switch kwargs.StyleSheet

      case 'twitter'
         stylesheet = ['https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/' ...
            'css/bootstrap.min.css'];

      otherwise
         error('Unrecognized StyleSheet')
   end

   % ContainerType
   switch kwargs.ContainerType

      case 'none'

         % do nothing - use the figure
         parent = fig;

      case 'flow'
         % Create two side-by-side panels
         parent = uiflowcontainer('v0', 'FlowDirection', 'lefttoright');

      otherwise
         error('Unrecognized ContainerType')
   end

   % Clean up the content
   content = regexprep(content, '^\s*', '');
   content = regexprep(content, '\n  ', '\n');

   %% Setup java interface

   % Create a java control because the builtin editbox doesn't
   % easily return the current value
   je = javax.swing.JEditorPane('text', content);
   jp = javax.swing.JScrollPane(je);

   originalWarnings = warning();
   warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
   [~, hcomp] = javacomponent(jp, [], parent);
   set(hcomp, 'Position', [0 0 0.5 1])
   warning(originalWarnings);

   %% Construct the MarkdownPanel object
   panel = MarkdownPanel( ...
      'Content',      content, ...
      'Parent',       parent, ...
      'StyleSheets',  stylesheet, ...
      'Classes',      'container');

   % Set the option to enable smooth live previews
   panel.Options.smoothLivePreview = true;

   % % Set the content again - without this it doesn't render in my testing, and
   % the pause length depends on the content and overall configuration - 0.02
   % seconds worked from a script with a simple figure window parent, but 0.1
   % was needed here.
   % pause(0.01)

   % This also appears to work, maybe drawnow introduces a sufficient delay
   drawnow
   set(panel, 'Content', content)

   %% Setup a timer to refresh the MarkdownPanel periodically

   % Note: With the timer, the drawnow, set(panel, 'Content', ...) is not
   % needed, but retain it for reference and/or if the time should be removed.
   timerFcn = @(s,e) set(panel, 'Content', char(je.getText()));

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

   %%
   if nargout
      varargout{1} = panel;
   end
end
