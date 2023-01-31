function mkfunction(name,varargin)
%MKFUNCTION make new function file from function template
%
%  mkfunction('myfunc') creates a new function file
%  matfunclib/libdata/myfunc/myfunc.m with default function template for 
%  parser style IP which means inputParser.
% 
%  mkfunction('myfunc','library','libdata','parser','IP') creates a new function
%  file matfunclib/libdata/myfunc/myfunc.m with default function template for
%  parser style IP which means inputParser. Other IP options are 'MP' for
%  magicParser, 'OP' for optionParser, and 'ArgList' for arguments-block.
% 
%  See also

%------------------------------------------------------------------------------
p              = inputParser;
p.FunctionName = mfilename;

addRequired(   p,'funcname',              @(x)ischar(x)  );
addParameter(  p,'library',   'unsorted', @(x)ischar(x)  );
addParameter(  p,'project',   'unsorted', @(x)ischar(x)  );
addParameter(  p,'parser',    'MIP',      @(x)ischar(x)  );
   
% % now that i understand addOptional, this may work:
% validlib    = @(x)any(validatestring(x,functiondirectorylist));
% validproj   = @(x)any(validatestring(x,projectdirectorylist));
% validparser = @(x)any(validatestring(x,{'MIP','IP','ArgList'}));
% 
% addRequired(   p,'funcname',              @(x)ischar(x)  );
% addOptional(   p,'library',   'unsorted', validlib       );
% addOptional(   p,'project',   'unsorted', validproj      );
% addOptional(   p,'parser',    'MIP',      validparser    );
% 
% i think inputs and outputs will need to be structures to distinguish
% required, parameter, optional, etc. but don't have time to sort it out rn
% addParameter(  p,'inputs',    {'x'},      @(x)iscell(x)  );
% addParameter(  p,'outputs',   {'x'},      @(x)iscell(x)  );
   
parse(p,name,varargin{:});

funcname = p.Results.funcname;
library  = p.Results.library;
project  = p.Results.project;
parser   = p.Results.parser;
%inputs   = p.Results.inputs;
%outputs  = p.Results.outputs;
%------------------------------------------------------------------------------

% keep the library or project parent folder
parent = library;
if library == "unsorted" && project == "unsorted"
   parent = "unsorted";
elseif library == "unsorted"
   parent = project;
end

% first check if the function exists
if ~isempty(which(funcname))
   error('function exists')
end

% get the function directory path and full path to new function filename
[functionpath,filenamepath] = parseFunctionPath(funcname,library,project);

% first try adding the path in case it exists but isn't on path - if the
% path doesn't exist, it won't issue an error (but addpath alone, without
% genpath, will issue an error)
addpath(genpath(functionpath));

if exist(functionpath,'dir')

   % function already exists, append _tmp to copy files
   mkappendfunc(functionpath,funcname,parent,parser);
   %mkappendfunc(functionpath,funcname,parser,inputs,outputs);

else
   % function doesn't exist, make a new one
   system(sprintf('mkdir %s',functionpath));
   addpath(genpath(functionpath));

   mknewfunc(functionpath,filenamepath,funcname,parent,parser);
   %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
end


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
fid         = fopen(filenamepath);
wholefile   = fscanf(fid,'%c');     fclose(fid);

wholefile   = strrep(wholefile,'FUNCNAME',upper(funcname));
wholefile   = strrep(wholefile,'funcname',funcname);
wholefile   = strrep(wholefile,'functemplate',funcname);

% REPLACE DD-MMM-YYYY with the data
wholefile   = strrep(wholefile,'DD-MMM-YYYY',date);

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
      wholefile = strrep(wholefile,'X','[Z,R]');
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

% write it over again
fid = fopen(filenamepath, 'wt');
fprintf(fid,'%c',wholefile); fclose(fid);

%----------------------------------
% repeat for functionSignature file
%----------------------------------

% copy the json template for inputParser functions
if parser == "IP" || parser == "MIP"

   copyjsontemplate(functionpath);           % specify path

   fid         = fopen([functionpath 'functionSignatures.json']);
   wholefile   = fscanf(fid,'%c');     fclose(fid);     
   wholefile   = strrep(wholefile,'funcname',funcname);
   fid         = fopen([functionpath 'functionSignatures.json'], 'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);
end

%----------------------------------
% postmk actions
%----------------------------------

% go to the new directory and open the new function file and json file
cd(functionpath);
edit(filenamepath);

% if a signature file already exists, open it, otherwise edit the _tmp
if exist([functionpath 'functionSignatures.json'],'file') == 2
   edit('functionSignatures.json');
end
% NOTE: with new functionality of copyjsontemplate, it will check for an
% existing one and if not, it will copy the template as
% functionSignatures.json, so above check swhould always open it

% doc JSON Representation of MATLAB Data Types
% doc validateattributes

function mkappendfunc(functionpath,funcname,parent,parser)
%mkappendfunc(functionpath,funcname,parser,inputs,outputs)
   
filenamepath   = [functionpath funcname '_tmp.m'];

msg = 'function folder exists, press ''y'' to copy function templates into directory as temporary files ';
msg = [msg 'or any other key to return\n'];
str = input(msg,'s');

if string(str) == "y"
   mknewfunc(functionpath,filenamepath,funcname,parent,parser);
   %mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs);
else
   return
end

function [functionpath,filenamepath] = parseFunctionPath(funcname,library,project)
      
% parse the function path. if library and project are both default
% "unsorted", OR if project is default "unsorted", use default function
% library. this gets both, and checks whether the function folder in the
% project dirs is 'func/' or 'functions/'

if project == "unsorted"

   functionpath = [getenv('MATLABFUNCTIONPATH') library '/' funcname '/'];

elseif project ~= "unsorted" && library == "unsorted"

   % assume the project is a matlab project
   projectpath = [getenv('MATLABPROJECTPATH') project];
   
   if ~isfolder(projectpath)
      projectpath = [getenv('USERPROJECTPATH') project];
      
      if ~isfolder(projectpath)
         error('project path not found')
      end
   end

   % this makes 'func/' the default which will get created if requested
   if isfolder([projectpath '/functions/'])

      functionpath = [projectpath '/functions/' funcname '/'];
      
   elseif isfolder([projectpath '/func/'])

      functionpath = [projectpath '/func/' funcname '/'];
      
   else

      functionpath = [projectpath '/' funcname '/'];
   end
end

filenamepath   = [functionpath funcname '.m'];

   