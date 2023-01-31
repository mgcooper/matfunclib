function msg = manager(cmd,varargin)
%MANAGER project manager, currently a wrapper around projects.m
% 
%  msg = MANAGER(cmd) description
%  msg = MANAGER(cmd,'name1',value1) description
%  msg = MANAGER(cmd,'name1',value1,'name2',value2) description
%  msg = MANAGER(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 09-Jan-2023, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = 'manager';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

% this is the command list for 'projects.m'. however, available projects are
% interactively added to the command list function sigs, just like 'workon', so
% this only gets me the default commands. but I can still use this to do
% something like manager open baseflow instead of projects open baseflow b/c
% tab-completing manager is instantaneous wheres projects has a bunch of
% interference. 
cmdlist = {'active','close','default','delete','list','load','open','rename','save','show'};
validcmd = @(x)any(validatestring(cmd,cmdlist));

% optlist = {''};
% validopt = @(x)any(validatestring(opt,optlist));
validopt = @(x)ischarlike(x);

p.addRequired(    'cmd',                     validcmd             );
p.addOptional(    'opt',         'none',     validopt             );
% p.addOptional(    'opt',         'none',     validopt             );
% p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

parse(p,cmd,varargin{:});

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

switch cmd
   case 'show'
      disp([newline, '  Project Name: ',getactiveproject,newline, ...
         'Project Folder: ',getactiveproject('folder'),newline])
      varargout = {};
   otherwise
      msg = projects(cmd,varargin{:});
end
      

% if nargout==0
%   varargout = {}; 
% end

% TODO:
% need a setup function that sets the paths, builds the projectdirectory, etc.
% in there, make a restricted folder to save directory backups

% mkdir restricted
% fileattrib restricted -w

% MOVED out of todo_manager:

% manager is turning out to have three main functions:
% 1) managing projects
% 2) managing toolboxes
% 3) managing functions
% 
% to manage projects, it manages the workspace in general, e.g. savetabs,
% setpath. 
% 
% so I created folder functools/ to represent that functionality

% add toolbox dictionary to cdtb and any other script that relies on tbname
% as input so it autocompletes just like activate/deactivate

% option to build an entirely new dictionary and toolboxdirectory from an
% existing folder

% methods to handle sub-folders within toolboxes e.g. we have situations
% with full blown toolboxes like ridgepack, and then basic utilities like
% kearney's functions, many of which I put into 'plotting'







