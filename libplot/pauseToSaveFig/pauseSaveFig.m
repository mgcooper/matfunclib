function pauseSaveFig(savekey,filename,obj,varargin)
   %PAUSESAVEFIG Pause and save a figure if keyboard key 'savekey' is pressed
   %
   % pauseSaveFig(savekey,filename) pauses and waits for savekey to save the
   % current figure using filename
   %
   % pauseSaveFig(savekey,filename,hobj) pauses and waits for savekey to save
   % the figure designated by hobj using filename
   %
   % pauseSaveFig(__,'Resolution',res) passes Resolution parameter to
   % exportgraphics
   %
   % pauseSaveFig(__,'pausetosave',true/false) turns on/off the pause behavior.
   % If true, program execution is paused until savekey is pressed. If false,
   % figures are saved without pausing.
   %
   % See also:

   [filename, savekey, obj, figres, pausetosave] = parseinputs( ...
      savekey,filename,obj,mfilename,varargin{:});

   % convert the provided keys to ascii numbers
   savekey = double(savekey);

   if pausetosave == true

      msg = ['press ' savekey ' to save the figure, p to pause, '];
      msg = [msg 'or any other key to continue without saving'];

      disp(msg);

      ch = getkey();
      if ch==savekey
         exportgraphics(obj,filename,'Resolution',figres);
         disp('figure saved, press any key to continue');
         commandwindow
         pause;
      elseif ch==112
         commandwindow
         pause;
      else
         commandwindow
      end
   else
      exportgraphics(gcf,filename,'Resolution',300);
      commandwindow
   end
end

% parse inputs
function [filename, savekey, obj, figres, pausetosave] = parseinputs( ...
      savekey,filename,obj,funcname,varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = true;
   parser.addRequired('savekey', @ischar);
   parser.addRequired('filename', @ischar);
   parser.addOptional('obj', gcf, @isgraphics);
   parser.addParameter('Resolution', 300, @isnumeric);
   parser.addParameter('pausetosave', true, @islogical);
   parser.addParameter('pauselogical', true, @ischar);
   % NOTE: pauselogical not implemented, it would be a logical condition that
   % determines whether to pause or not like if(counter<maxiter); pause;
   parser.parse(savekey, filename, obj, varargin{:});

   obj = parser.Results.obj;
   figres = parser.Results.Resolution;
   savekey = parser.Results.savekey;
   filename = parser.Results.filename;
   pausetosave = parser.Results.pausetosave;
end

%% pausekey version

% an older version had an option to pause in addition to save, but since this
% function is designed to be used with pause, it should only have an otion to
% save, and pause is used whether savekey isn't entered or not.

% To implement a 'pausekey' option in the parser:
% defaultpausekey = 'none'; % 'p';
% addOptional(p, 'pausekey', defaultpausekey, @ischar);
% pausekey = p.Results.pausekey;


% if string(pausekey) == "none"
%    msg   = ['press ' savekey ' to save the figure, '];
%    msg   = [msg 'or any other key to continue'];
% else
%    msg   = ['press ' savekey ' to save the figure,' pausekey];
%    msg   = [msg ' to pause code, or any other key to continue'];
% end
%
% disp(msg);
%
% % convert the provided keys to ascii numbers
% savekey   = double(savekey);
% pausekey  = double(pausekey);
%
% ch = getkey();
%
% if ch==savekey
%    exportgraphics(gcf,filenamepath,'Resolution',figres);
% end
%
% if string(pausekey) ~= "none"
%    pause;
% end
