function pauseSaveFig(savekey,filename,obj,varargin)
%PAUSESAVEFIG pause and save a figure if keyboard key 'savekey' is pressed
%
% pauseSaveFig(savekey,filename) pauses and waits for savekey to save the
% current figure using filename
%
% pauseSaveFig(savekey,filename,hobj) pauses and waits for savekey to save the
% figure designated by hobj using filename
%
% pauseSaveFig(__,'Resolution',res) passes Resolution parameter to
% exportgraphics
%
% pauseSaveFig(__,'pausetosave',true/false) turns on/off the pause behavior. If
% true, program execution is paused until savekey is pressed. If false, figures
% are saved without pausing.
%
% See also:

%% parse inputs
[filename, savekey, obj, figres, pausetosave] = parseinputs( ...
   savekey,filename,obj,mfilename,varargin{:});

%% main

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
   exportgraphics(gcf,fname,'Resolution',300);
   commandwindow
end


% parse inputs
function [filename, savekey, obj, figres, pausetosave] = parseinputs( ...
   savekey,filename,obj,funcname,varargin)
p = inputParser;
p.FunctionName = funcname;
p.CaseSensitive = true;

addRequired(   p,'savekey',               @(x)ischar(x)     );
addRequired(   p,'filename',              @(x)ischar(x)     );
addOptional(   p,'obj',             gcf,  @(x)isgraphics(x) );
addParameter(  p,'Resolution',      300,  @(x)isnumeric(x)  );
addParameter(  p,'pausetosave',     true, @(x)islogical(x)  );
addParameter(  p,'pauselogical',    true, @(x)ischar(x)     );

% NOTE: pauselogical not implemented but the idea is to have a logical condition
% that determines whether to pause or not like if(counter<maxiter); pause;

parse(p,savekey,filename,obj,varargin{:});

filename    = p.Results.filename;
savekey     = p.Results.savekey;
obj         = p.Results.obj;
figres      = p.Results.Resolution;
pausetosave = p.Results.pausetosave;

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
