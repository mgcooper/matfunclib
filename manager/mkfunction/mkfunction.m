function mkfunction(funcname,varargin)
%MKFUNCTION make new function file from function template
%
%  mkfunction('myfunc') creates a new function file matfunclib/myfunc.m with
%  default function template for parser style IP which means inputParser.
% 
%  mkfunction('myfunc','library','libdata','parser','IP') creates a new function
%  file matfunclib/libdata/myfunc.m with default function template for
%  parser style IP which means inputParser. Other IP options are 'MP' for
%  magicParser, 'OP' for optionParser, 'NP' for no parser, and 'ArgList' for
%  arguments-block. 
% 
%  See also

%% parse inputs
[funcname, library, project, parser] = parseinputs(funcname, mfilename, varargin{:});

%% main function

% keep the library or project parent folder
parent = library;
if library == "unsorted" && project == "unsorted"
   parent = "unsorted";
elseif library == "unsorted"
   parent = project;
end

% first check if the function exists. NOTE: if this check is ever removed, pay
% attention to how _tmp is appended ot the function name given that the prior
% behavior that ringfenced the new function in a funcname/ folder was removed
if ~isempty(which(funcname))
   error(['function exists as ' which(funcname)])
end

% get the function directory path and full path to new function filename
[functionpath,filenamepath] = parseFunctionPath(funcname,library,project);

% first try adding the path in case it exists but isn't on path - if the
% path doesn't exist, it won't issue an error (but addpath alone, without
% genpath, will issue an error). NOTE: shouldn't be necessary now that
% ringfenced folder is not created, but doesn't hurt.
pathadd(functionpath);

% isfile should be sufficient to catch the case where parseFunctionPath fences
% off the new function in a parent folder with the same name as the function to
% avoid over-riding functionSignatures

if isfile(filenamepath) % isfolder(functionpath) || isfile(filenamepath)

   % function already exists, append _tmp to copy files
   mkappendfunc(functionpath,funcname,parent,parser);
   %mkappendfunc(functionpath,funcname,parser,inputs,outputs);

else
   
   % function doesn't exist, make a new folder if parent folder doesn't exist
   if ~isfolder(functionpath)
      system(sprintf('mkdir %s',functionpath));
   end

   pathadd(functionpath);

   mknewfunc(functionpath,filenamepath,funcname,parent,parser);
   %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
end


% Make New Function
function mknewfunc(functionpath,filenamepath,funcname,parent,parser)
%function mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs)
   
%---------------------------------------
% copy the function template and edit it
%---------------------------------------

% copy the function template 
copyfunctemplate(filenamepath,parser);    % specify path w/file name 

% note: check if there's any benefit to fileread vs fscanf
% wholefile = fileread(filenamepath);

% REPLACE 'funcname' with the actual function name in the function file
fid = fopen(filenamepath);
wholefile = fscanf(fid,'%c');     fclose(fid);

% Strip out the license so the strrep commands do not rewrite any content
license = wholefile(strfind(wholefile, "%% LICENSE"):end);
wholefile = wholefile(1:strfind(wholefile, "%% LICENSE")-1);

wholefile = strrep(wholefile,'FUNCNAME',upper(funcname));
wholefile = strrep(wholefile,'funcname',funcname);
wholefile = strrep(wholefile,'functemplate',funcname);

% REPLACE DD-MMM-YYYY on AUTHOR line with the current date
try %#ok<*TRYNC> 
   wholefile = strrep(wholefile,'DD-MMM-YYYY',char(datetime("today")));
end

% REPLACE YYYY on COPYRIGHT line with the current YEAR
try
   wholefile = strrep(wholefile,'Copyright (c) YYYY', ...
      ['Copyright (c) ' num2str(year(datetime('today')))]);
end

% REPLACE the input varname with default library varnames
switch parent
   
   case {'libarrays'}
      wholefile = strrep(wholefile,'X','A'); % or M for matrix
      wholefile = strrep(wholefile,'Y','A');
      
   case {'libcells'}
      wholefile = strrep(wholefile,'X','C');
      wholefile = strrep(wholefile,'Y','C');
      
   case {'liblogic'}

      wholefile = strrep(wholefile,'Y','TF');
      
   case {'libplot'}
      wholefile = strrep(wholefile,'X','H');
      wholefile = strrep(wholefile,'Y','H'); % handle (graphics object array) 

   case {'libraster'}
      wholefile = strrep(wholefile,'X','Z,R');
      wholefile = strrep(wholefile,'Y','[Z,R]');

   case {'libspatial'}
      wholefile = strrep(wholefile,'X','Geom');
      wholefile = strrep(wholefile,'Y','S');     
      
   case {'libstruct'}
      wholefile = strrep(wholefile,'X','S');
      wholefile = strrep(wholefile,'Y','S');
      
   case {'libstr'}
      wholefile = strrep(wholefile,'X','str');
      wholefile = strrep(wholefile,'Y','str');

   case {'libtable','libtime'}
      wholefile = strrep(wholefile,'X','T');
      wholefile = strrep(wholefile,'Y','T');
      wholefile = strrep(wholefile,'@(x)isnumeric(x)','@(x)istable(x)|istimetable(x)');

   case {'manager','libsys'}
      wholefile = strrep(wholefile,'X','cmd');
      wholefile = strrep(wholefile,'Y','msg');
      
end

% % for custom i/o, need to read the first line and replace [Z,R] and x
% requiredinputfind = 'x';
% for n = 1:numel(inputs)
%    requiredinputrepl = inputs{n};
%    wholefile = '';
% end

% replace the license
wholefile = [wholefile license];

% write it over again
fid = fopen(filenamepath, 'wt');
fprintf(fid,'%c',wholefile); fclose(fid);

%----------------------------------
% repeat for functionSignature file
%----------------------------------

% copy the json template for inputParser functions
if parser == "IP" || parser == "MP" || parser == "OP"

   % note: copyjsontemplate checks if functionSignatures.json exists, but 
   jsonfilename = ['functionSignatures.json.' funcname];

   copyjsontemplate(functionpath,jsonfilename); % specify full path

   fid = fopen(fullfile(functionpath,jsonfilename));
   wholefile = fscanf(fid,'%c'); fclose(fid);     
   wholefile = strrep(wholefile,'funcname',funcname);
   fid = fopen(fullfile(functionpath,jsonfilename),'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);

   % open the new one. if a functionSignatures.json exists, it is opened below
   if isfile(fullfile(functionpath,jsonfilename))
      edit(fullfile(functionpath,jsonfilename));
   end
end

%----------------------------------
% postmk actions
%----------------------------------

% go to the new directory and open the new function file and json file
cd(functionpath);
edit(filenamepath);

% if a signature file already exists, open it, otherwise edit the _tmp
if isfile(fullfile(functionpath,'functionSignatures.json'))
   edit('functionSignatures.json');
end

% doc JSON Representation of MATLAB Data Types
% doc validateattributes


function mkappendfunc(functionpath,funcname,parent,parser)
%mkappendfunc(functionpath,funcname,parser,inputs,outputs)
   
filenamepath = fullfile(functionpath,[funcname '_tmp.m']);

msg = 'function exists, press ''y'' to create a _tmp function ';
msg = [msg 'or any other key to return\n'];
str = input(msg,'s');

if string(str) == "y"
   mknewfunc(functionpath,filenamepath,funcname,parent,parser);
   %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
else
   return
end

% Function Path Parser
function [functionpath,filenamepath] = parseFunctionPath(funcname,library,project)
      
% parse the function path. if library and project are both default
% "unsorted", OR if project is default "unsorted", use default function
% library. this gets both, and checks whether the function folder in the
% project dirs is '+projectname', 'func/', 'functions/'

if project == "unsorted"

   % 10 Feb 2023, removed function name folder
   functionpath = fullfile(getenv('MATLABFUNCTIONPATH'),library);
   %functionpath = fullfile(getenv('MATLABFUNCTIONPATH'),library,funcname);

elseif project ~= "unsorted" && library == "unsorted"

   % assume the project is a matlab project
   projectpath = fullfile(getenv('MATLABPROJECTPATH'),project);
   
   if ~isfolder(projectpath)
      projectpath = fullfile(getenv('USERPROJECTPATH'),project);
      
      if ~isfolder(projectpath)
         error('project path not found')
      end
   end

   % this checks for a package folder
   if isfolder(fullfile(projectpath,['+' project]))
      
      functionpath = fullfile(projectpath,['+' project]);
   
   % this makes 'func/' the default which will get created if requested
   elseif isfolder(fullfile(projectpath,'functions'))

      % 10 Feb 2023, removed function name folder
      functionpath = fullfile(projectpath,'functions');
      %functionpath = fullfile(projectpath,'functions',funcname);
      
   elseif isfolder(fullfile(projectpath,'func'))

      % 10 Feb 2023, removed function name folder
      functionpath = fullfile(projectpath,'func');
      %functionpath = fullfile(projectpath,'func',funcname);
      
   else

      % 10 Feb 2023, in this case, use the function name folder
      functionpath = fullfile(projectpath,funcname);
   end
end

filenamepath = fullfile(functionpath,[funcname '.m']);


% Input Parser
function [funcname, library, project, parser] = parseinputs(funcname, ...
   mfilename, varargin)

p = inputParser;
p.FunctionName = mfilename;

addRequired(   p,'funcname', @(x)ischar(x) );
addParameter(  p,'library', 'unsorted', @(x)ischar(x) );
addParameter(  p,'project', 'unsorted', @(x)ischar(x) );
addParameter(  p,'parser', 'MP', @(x)ischar(x) );
   
% % now that i understand addOptional, this may work:
% validlib    = @(x)any(validatestring(x,functiondirectorylist));
% validproj   = @(x)any(validatestring(x,projectdirectorylist));
% validparser = @(x)any(validatestring(x,{'MP','IP','AP','OP','NP'}));
% 
% addRequired(   p,'funcname',              @(x)ischar(x)  );
% addOptional(   p,'library',   'unsorted', validlib       );
% addOptional(   p,'project',   'unsorted', validproj      );
% addOptional(   p,'parser',    'MP',       validparser    );
% 
% i think inputs and outputs will need to be structures to distinguish
% required, parameter, optional, etc. but don't have time to sort it out rn
% addParameter(  p,'inputs',    {'x'},      @(x)iscell(x)  );
% addParameter(  p,'outputs',   {'x'},      @(x)iscell(x)  );
   
parse(p,funcname,varargin{:});

library = p.Results.library;
project = p.Results.project;
parser = p.Results.parser;
%inputs = p.Results.inputs;
%outputs = p.Results.outputs;
   