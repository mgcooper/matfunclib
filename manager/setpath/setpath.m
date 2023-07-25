function pathstr = setpath(pathstr,varargin)
%SETPATH return full path string or (if no output request) add the full path
% 
%  Syntax
%  
%     pathstr = setpath(pathstr,'project') returns the full path to input
%     pathstr located in MATLABPROJECTPATH
% 
% See also: pathadd


% parse inputs
[pathstr, pathtype, postset] = parseinputs(mfilename, pathstr, varargin{:});

% main function

% first determine what type of path (matlab, project, or data path). NOTE: the
% 'otherwise' option was supposed to negate the need to pass 'user' for a full
% path, but it doesn't work b/c default option is 'matlab' for convenience
switch pathtype
   case 'matlab'
      pathroot = getenv('MATLABUSERPATH');
   case 'project'
      pathroot = getenv('MATLABPROJECTPATH');
   case 'data'
      pathroot = getenv('USERDATAPATH');
   case 'user'
      pathroot = '';       % assume the full path is passed in
   otherwise
      pathroot = pathtype; % assume the root is passed in
end

if isstruct(pathstr)
   
   pathstruct = pathstr;
   fields = fieldnames(pathstruct);
   pathstr = cell(numel(fields), 1);

   for n = 1:length(fields)
      pathstr{n} = fullfile(pathroot, pathstruct.(fields{n}));
   end

elseif ischar(pathstr)
   pathstr = fullfile(pathroot,pathstr);
end

% if postset = 'goto', cd to the path
if strcmp(postset,'goto')
   cd(pathstr)
elseif strcmp(postset,'add')
   pathadd(pathstr);
end

%% INPUT PARSER
function [pathstr, pathtype, postset] = parseinputs(funcname, pathstr, varargin)

validpathtypes = @(x)any(validatestring(x,{'matlab','project','data','user'}));
validpostset = @(x)any(validatestring(x,{'goto','none','add'}));

parser = inputParser;
parser.FunctionName = funcname;
parser.addRequired( 'pathstr', @(x)ischar(x)|isstruct(x));
parser.addOptional( 'pathtype', 'matlab', validpathtypes);
parser.addOptional( 'postset',  'none', validpostset);
parser.parse(pathstr, varargin{:});

pathtype = parser.Results.pathtype;
postset  = parser.Results.postset;
