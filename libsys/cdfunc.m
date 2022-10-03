function cdfunc(funcname)
%CDFUNC cd to foldor containing function funcname

% parse inputs
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
p=inputParser;
p.FunctionName='cdfunc';
p.PartialMatching=false;
addRequired(p,'funcname',@(x)ischar(x));
parse(p,'funcname');

% try adding the func path by assuming it's parent folder has same name
mainfuncpath = getenv('MATLABFUNCTIONPATH');

% add all subfolders to the path in case the function was just made
addpath(genpath(mainfuncpath));

% % not sure if this is possible, keeping for reference   
%    % in case of accidentally not passing in a char
%    if ~isstr(funcname)
%       funcname = string(funcname);
%    end

% if the function name is provided, this finds it's location, including built-ins.
if nargin==1
   if ~contains(funcname,'.m')
      funcname = [funcname '.m'];
   end
   funcpath = strrep(which(funcname),funcname,'');
else
% otherwise, go to the function directory
   funcpath = mainfuncpath;
end

cd(funcpath)

% % this was before I realized i could just add the entire funcpath to the path

%    % if the function name is provided, this finds it's location
%    if nargin==2
%       addpath(genpath([mainfuncpath category '/' funcname]));
%       funcpath = strrep(which([funcname '.m']),[funcname '.m'],'');
%    elseif nargin==1
%       addpath(genpath([mainfuncpath funcname '/' funcname '.m']));
%       funcpath = strrep(which([funcname '.m']),[funcname '.m'],'');
%    else
%    % otherwise, go to the function directory
%       funcpath = mainfuncpath;
%    end
%    
%    cd(funcpath)

