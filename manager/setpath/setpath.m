function pathstr = setpath(pathstr,varargin)
%SETPATH return full path string or (if no output request) add the full path
% 
%  Syntax
%  
%     pathstr = setpath(pathstr,'project') returns the full path to input
%     pathstr located in MATLABPROJECTPATH
% 
%  string (char) 


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


function [pathstr, pathtype, postset] = parseinputs(funcname, pathstr, varargin)

validpathtypes = @(x)any(validatestring(x,{'matlab','project','data','user'}));
validpostset = @(x)any(validatestring(x,{'goto','none','add'}));

p = inputParser;
p.FunctionName = funcname;

p.addRequired( 'pathstr', @(x)ischar(x)|isstruct(x));
p.addOptional( 'pathtype', 'matlab', validpathtypes);
p.addOptional( 'postset',  'none', validpostset);

p.parse(pathstr, varargin{:});

pathtype = p.Results.pathtype;
postset  = p.Results.postset;

% March 2023, I decided to always pass back the path that way I can use it in
% file building statements like fullpath(setpath('/path/to/data','data'))
% and instead, addpath is an option

% % parse outputs
% switch nargout
%    case 1
%       % return the full path
%       varargout{1} = pathstr;
%    case 0
%       % add the path, don't return it
%       addpath(genpath(pathstr));
% end




% the old way that required knowing which computer I was on:

% homepath = pwd;
%
% if isstruct(path)
%     fields = fieldnames(path);
%
%     for n = 1:length(fields)
%
%         pathname = path.(fields{n});
%
%         if strcmp(homepath(8:14),'coop558')
%             pathname = ['/Users/coop558/Dropbox/MATLAB/' pathname];
%         elseif strcmp(homepath(8:17),'mattcooper')
%             pathname = ['/Users/mattcooper/Dropbox/MATLAB/' pathname];
%         end
%
%         path.(fields{n}) = pathname;
%     end
%
% elseif ischar(path)
%
%     if strcmp(homepath(8:14),'coop558')
%             path = ['/Users/coop558/Dropbox/MATLAB/' path];
%     elseif strcmp(homepath(8:17),'mattcooper')
%             path = ['/Users/mattcooper/Dropbox/MATLAB/' path];
%     end
%
% end
%
%
%
