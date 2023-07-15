function Info = getFunctionDependencies(varargin)
%getFunctionDependencies get a list of functions that are required by a user
%provided function
% 
%  Info = getFunctionDependencies(funcname) returns Info which contains lists of
%  required functions (flist) and products (plist) required to run the function
%  specified by input funcname. 
% 
%  Info = getFunctionDependencies(funcname,'refpath') compares the required
%  functions in flist to functions in folder specified by 'refpath' to indicate
%  if required files are missing.
% 
% Example
%  
% 
% Matt Cooper, 23-Dec-2022, https://github.com/mgcooper
% 
% See also getFunctionConflicts


% parse inputs
[funcname, funcpath, libname, projname, refpath] = parseinputs( ...
   mfilename, varargin{:});

% main function
isfuncpath = ~isempty(funcpath);
islibrary = ~isempty(libname);
isproject = ~isempty(projname);
isfuncname = ~isempty(funcname);
isrefpath = ~isempty(refpath);

if ~isfuncname && ~islibrary && ~isfuncpath
   error('specify function name or function library');
end

% figure out if a single file or folder of files is requested
if isfuncpath && ~isfolder(funcpath)
   % if a full path to a function file is passed in, treat it the same as funcname
   isfuncname = true;
elseif islibrary
   % if a library is requested, build a full path
   funcpath = fullfile(getenv('MATLABFUNCTIONPATH'),libname);
elseif isproject
   % if a project is requested, build a full path
   funcpath = fullfile(getenv('MATLABPROJECTPATH'),projname);
elseif isfuncname
   % if a function name is requested, build a full path
   funcpath = which(funcname); % doesn't matter which one is found
end

% if a full path to a function file is passed in, use which -all and return
if isfuncname
   flist = dir(fullfile(funcpath));
   [flist,plist] = finddependencies(flist,1);

else % check all files in the funcpath

   flist = getlist(funcpath,'*m','subdirs',true);
   numfiles = numel(flist);

   % filenames to ignore
   ignore   = {'readme','test','temp'};

   for n = 1:numfiles

      % we don't want the full path otherwise which only finds it
      % f = fullfile(funcpath,filelist(n).name);

      if contains(flist(n).name,ignore)
         continue
      else
         [flist_n,plist_n] = finddependencies(flist,n);
      end
      flist = [flist; flist_n];
      plist = [plist; plist_n];
   end
end

Info.flist = unique(flist);
Info.plist = plist;

% if a reference path is provided, find missing functions
if isrefpath
   Info.fmissing = checkdependencies(flist,refpath);
end

%% subfunctions

function [flist,plist] = finddependencies(filelist,idx)
funcname = filelist(idx).name;
[flist,plist] = matlab.codetools.requiredFilesAndProducts(funcname);
flist = transpose(flist); plist = transpose(plist);
% funcname = 'skinmodel.m';

% reflist = dir('functions/*.m');
% % reflist = 
% flist = cell2table(flist,'VariableNames',{'function_dependencies'});

function flist = checkdependencies(flist,refpath)
reflist = getlist(refpath,'*','subdirs',true);
reflist = {reflist.name}';
missing = false(numel(flist),1);
for n = 1:numel(flist)
   [~,fname,ext] = fileparts(flist{n});
   missing(n) = ~ismember([fname,ext],reflist);
end
flist = flist(missing);


%% input parsing
function [funcname, funcpath, libname, projname, refpath] = parseinputs( ...
   mfuncname, varargin)

p = inputParser;
p.FunctionName = mfuncname;
p.CaseSensitive = true;
p.KeepUnmatched = true;

% use contains on funcname b/c listallmfunctions includes .m but it is
% convenient to pass in a function name w/o .m
validfuncname = @(x) any(contains(listallmfunctions,x));
validlibrarys = @(x) any(ismember(functiondirectorylist,x));
validprojects = @(x) any(ismember(projectdirectorylist,x));
validfuncpath = @(x) ischar(x)&&~any(ismember(x,{'library','project','funcname'}));

% NOTE: this parsing came from getFunctionConflicts which had funcpath as the
% first optional argument so I htink the validfuncpath check above is the other
% parameter names b/c I thought parsing might fail, but it seemed to work when I
% added the project parameter (which isn't in getFunctionConflicts) so maybe it
% isn't necessary to exclude the parameter names.

p.addOptional('funcname', '', validfuncname);
p.addParameter('funcpath', '', validfuncpath);
p.addParameter('libname', '', validlibrarys);
p.addParameter('projname', '', validprojects);
p.addParameter('refpath', '', @ischarlike);

p.parse(varargin{:});

funcname = p.Results.funcname;
funcpath = p.Results.funcpath;
libname = p.Results.libname;
projname = p.Results.projname;
refpath = p.Results.refpath;

