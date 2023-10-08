function varargout = macfig(varargin)
   %MACFIG make figure on mac

   % see maxfig and maximize for setting the max figure size
   [monitor, size, args] = parseinputs(mfilename, varargin{:});

   % for compatibility:
   % mac, large: figure('Position',[1 1 658  576]);
   % mac, full: figure('Position',[1 1 1152 720]);
   % 'mac' and 'full' are identical - they fill the screen
   % 'half', 'large', and 'horizontal' fill the top half
   % 'vertical' fills the half vertically
   % 'quarter' and 'medium' are identical, they fill a quarter horizontally
   % 'small' fills 1/16

   pos = get(0, 'MonitorPositions');
   switch monitor
      case 'mac'
         f = makeMacFigure(pos,size,args);
      case 'main'
         f = makeMainFigure(pos,size,args);
      case 'external'
         f = makeExternalFigure(pos,size,args);
   end

   if nargout == 1
      varargout{1} = f;
   end
end

function f = makeMacFigure(pos,size,varargs)

   % note, pos(1) is set by the os, I think, so if I set my external monitor to
   % be the primary monitor in System Pref's, then this makes a figure on the
   % external pos = pos(2,:);
   pos = pos(1,:);

   switch size
      case 'full'
         figpos = [pos(1) pos(2) pos(3) pos(4)];
      case 'horizontal'
         figpos = [pos(1) pos(3)/2 pos(3) pos(4)/2];
      case 'vertical'
         figpos = [pos(1) pos(2) pos(3)/2 pos(4)];
      case 'wide'
         figpos = [pos(1)*200 pos(2)*200 pos(3)/1.3 pos(4)/2];
      case 'large'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/1.75 pos(4)/1.25];
      case 'medium'
         figpos = [pos(3)/4 pos(4)/4 512   384]; % default fig size
         % figpos = [pos(3)/4 pos(4)/4 pos(3)/2.5 pos(4)/2];
      case 'small'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/3 pos(4)/2.5];
      otherwise
         figpos = [pos(1) pos(2) pos(3) pos(4)];
   end
   f  = figure('Position',figpos,varargs{:});
end

function f = makeMainFigure(pos,size,varargs)

   pos = pos(3,:);

   switch size
      case 'full'
         figpos = [pos(1) pos(2) pos(3) pos(4)];
      case 'horizontal'
         figpos = [pos(1) pos(3)/2 pos(3) pos(4)/2];
      case 'vertical'
         figpos = [pos(1) pos(2) pos(3)/2 pos(4)];
      case 'large'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/1.75 pos(4)/1.25];
      case 'medium'
         figpos = [pos(3)/4 pos(4)/4 512   384]; % default fig size
         % figpos = [pos(3)/4 pos(4)/4 pos(3)/2.5 pos(4)/2];
      case 'small'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/3 pos(4)/2.5];
      otherwise
         figpos = [pos(1) pos(2) pos(3) pos(4)];
   end
   f  = figure('Position',figpos,varargs{:});
end

function f = makeExternalFigure(pos,size,varargs)

   pos = pos(2,:);

   switch size
      case 'full'
         figpos = [pos(1) pos(2) pos(3) pos(4)];
      case 'horizontal'
         figpos = [pos(1) pos(3)/2 pos(3) pos(4)/2];
      case 'vertical'
         figpos = [pos(1) pos(2) pos(3)/2 pos(4)];
      case 'large'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/1.75 pos(4)/1.25];
      case {'quarter','medium'}
         figpos = [pos(3)/4 pos(4)/4 pos(3)/2 pos(4)/2];
      case 'small'
         figpos = [pos(3)/4 pos(4)/4 pos(3)/3 pos(4)/2.5];
      otherwise
         figpos = [pos(1) pos(2) pos(3) pos(4)];
   end
   f = figure('Position',figpos,varargs{:});
end

%% Input Parser
function [monitor, size, args] = parseinputs(mfilename, varargin)
   
   validmonitor = @(x) any(validatestring(x,{'mac','main','external'}));
   
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = true;
   parser.KeepUnmatched = true;
   parser.addOptional('monitor', 'mac', validmonitor);
   parser.addParameter('size', 'full', @ischar);
   parse(parser,varargin{:});

   monitor = parser.Results.monitor;
   size = parser.Results.size;
   args = unmatched2varargin(parser.Unmatched);
end
