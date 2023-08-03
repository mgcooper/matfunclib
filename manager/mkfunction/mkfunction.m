function mkfunction(funcname,varargin)
%MKFUNCTION make new function file from function template
%
%  mkfunction('funcname') creates a new function file funcname.m using the
%  default function template for parser style IP which means inputParser.
% 
%  mkfunction('funcname','library','libdata','parser','IP') creates a new
%  function file MATLABFUNCTIONPATH/libdata/funcname.m with default function
%  template for parser style IP which means inputParser. Other IP options are
%  'MP' for magicParser, 'OP' for optionParser, 'NP' for no parser, and
%  'AP' for arguments-block parser. MATLABFUNCTIONPATH is defined by the
%  environment variable MATLABFUNCTIONPATH. If the environment variable
%  MATLABFUNCTIONPATH does not exist, then MATLABPROJECTPATH and USERPROJECTPATH
%  are checked and used if found. If none are found, USERPATH is used.
% 
%  See also

% TODO: add support for 'inputs' and 'outputs'

% parse inputs
[funcname, library, project, parser] = parseinputs(funcname, mfilename, varargin{:});

% main function
parent = library; % keep the library or project parent folder
if library == "unsorted" && project == "unsorted"
   parent = "unsorted";
elseif library == "unsorted"
   parent = project;
end

% check if the function exists. NOTE: if this check is ever removed, pay
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

end

% Make New Function
function mknewfunc(functionpath,filenamepath,funcname,parent,parser)
%function mknewfunc(functionpath,filenamepath,funcname,parser,inputs,outputs)
   
%---------------------------------------
% copy the function template and edit it
%---------------------------------------

% copy the function template and the test script template
testfuncpath = copyfunctemplate(filenamepath,parser);    % specify path w/file name 

% read in the testscript template, replace the function name, and write it back
wholefile = readinfile(testfuncpath);
wholefile = strpat(wholefile,'FUNCNAME',upper(funcname));
wholefile = strpat(wholefile,'funcname',funcname);
rewritefile(testfuncpath, wholefile)

% read in the function template file
wholefile = readinfile(filenamepath);

% strip out the license so the strrep commands do not rewrite any content
license = wholefile(strfind(wholefile, "%% LICENSE"):end);
wholefile = wholefile(1:strfind(wholefile, "%% LICENSE")-1);

% replace 'funcname' with the actual function name in the function file
wholefile = strpat(wholefile,'FUNCNAME',upper(funcname));
wholefile = strpat(wholefile,'funcname',funcname);
wholefile = strpat(wholefile,'functemplate',funcname);
wholefile = strpat(wholefile,'test_funcname',['test_' funcname]);

% REPLACE DD-MMM-YYYY on AUTHOR line with the current date
try %#ok<*TRYNC> 
   wholefile = strpat(wholefile,'DD-MMM-YYYY',char(datetime("today")));
end

% REPLACE YYYY on COPYRIGHT line with the current YEAR
try
   wholefile = strpat(wholefile,'Copyright (c) YYYY', ...
      ['Copyright (c) ' num2str(year(datetime('today')))]);
end

% REPLACE the input varname with default library varnames
switch parent
   
   case {'libarrays'}
      wholefile = strpat(wholefile,'X','A'); % or M for matrix
      wholefile = strpat(wholefile,'Y','A');
      
   case {'libcells'}
      wholefile = strpat(wholefile,'X','C');
      wholefile = strpat(wholefile,'Y','C');
      
   case {'liblogic'}

      wholefile = strpat(wholefile,'Y','TF');
      
   case {'libplot'}
      wholefile = strpat(wholefile,'X','H');
      wholefile = strpat(wholefile,'Y','H'); % handle (graphics object array) 

   case {'libraster'}
      wholefile = strpat(wholefile,'X','Z,R');
      wholefile = strpat(wholefile,'Y','[Z,R]');

   case {'libspatial'}
      wholefile = strpat(wholefile,'X','GEOM');
      wholefile = strpat(wholefile,'Y','S');     
      
   case {'libstruct'}
      wholefile = strpat(wholefile,'X','S');
      wholefile = strpat(wholefile,'Y','S');
      
   case {'libtext'}
      wholefile = strpat(wholefile,'X','STR');
      wholefile = strpat(wholefile,'Y','STR');

   case {'libtable','libtime'}
      wholefile = strpat(wholefile,'X','T');
      wholefile = strpat(wholefile,'Y','T');
      wholefile = strpat(wholefile,'f.validNumericVector','f.validTabular');

   case {'manager','libsys'}
      wholefile = strpat(wholefile,'X','CMD');
      wholefile = strpat(wholefile,'Y','MSG');
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
rewritefile(filenamepath, wholefile)

%----------------------------------
% repeat for functionSignature file
%----------------------------------

% copy the json template for inputParser functions
if ismember(parser, {'IP', 'MP', 'OP', 'NP'})

   % % specify full path for copyjsontemplate
   jsonfilename = ['functionSignatures.json.' funcname];
   copyjsontemplate(functionpath,jsonfilename);

   % read it in, replace funcname placeholder, and rewrite it
   wholefile = readinfile(fullfile(functionpath,jsonfilename));
   wholefile = strrep(wholefile,'funcname',funcname);
   rewritefile(fullfile(functionpath,jsonfilename), wholefile);

   % open the new one. if a functionSignatures.json exists, it is opened below
   if isfile(fullfile(functionpath,jsonfilename))
      edit(fullfile(functionpath,jsonfilename));
   end
end

%----------------------------------
% cleanup actions
%----------------------------------

% go to the new directory and open the new function file and json file
cd(functionpath);
edit(filenamepath);

% if a signature file already exists, open it, otherwise edit the _tmp
if isfile(fullfile(functionpath,'functionSignatures.json'))
   edit('functionSignatures.json');
end

end


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

end


% Function Path Parser
function [functionpath,filenamepath] = parseFunctionPath(funcname,library,project)
%PARSEFUNCTIONPATH parse the new function full path      

% If the mvenv environment vars are not set, use userpath
if all(cellfun('isempty', { ...
      getenv('MATLABFUNCTIONPATH'), ...
      getenv('MATLABPROJECTPATH'), ...
      getenv('USERPROJECTPATH') } ...
      ));
   functionpath = fullfile(userpath, funcname);
else

   % If library or project are default "unsorted", use the default function
   % library. For projects, check some predefined folders in the project
   % directory to save the new function file.
   
   if project == "unsorted"
      % library is either a valid sublibrary or is "unsorted"
      functionpath = fullfile(getenv('MATLABFUNCTIONPATH'),library);
   
      % this creates the function in a folder of the same name
      % functionpath = fullfile(getenv('MATLABFUNCTIONPATH'),library,funcname);
   
   elseif project ~= "unsorted" && library == "unsorted"
   
      % assume the project is a matlab project
      projectpath = fullfile(getenv('MATLABPROJECTPATH'),project);
      
      if ~isfolder(projectpath)
         projectpath = fullfile(getenv('USERPROJECTPATH'),project);
         
         if ~isfolder(projectpath)
            error('project path not found')
         end
      end
   
      % Check for a <project>/+<project> package folder
      if isfolder(fullfile(projectpath,['+' project]))
         functionpath = fullfile(projectpath,['+' project]);
      
      % Check for a <project>/toolbox/<+project> package folder
      elseif isfolder(fullfile(projectpath,['toolbox/+' project]))
         functionpath = fullfile(projectpath,['+' project]);
   
      % Check for a '<project>/toolbox/functions folder
      elseif isfolder(fullfile(projectpath,'toolbox/functions'))
         functionpath = fullfile(projectpath,'toolbox/functions');
         
      % Check for a '<project>/toolbox/internal folder
      elseif isfolder(fullfile(projectpath,'toolbox/internal'))
         functionpath = fullfile(projectpath,'toolbox/internal');
   
      % Check for a '<project>/sandbox folder
      elseif isfolder(fullfile(projectpath,'sandbox'))
         functionpath = fullfile(projectpath,'sandbox');
   
      else % otherwise, create a <project>/<funcname> folder
         functionpath = fullfile(projectpath,funcname);
   
      end
   end
end
filenamepath = fullfile(functionpath,[funcname '.m']);
end


function wholefile = readinfile(filenamepath);
%read in the file
   fid = fopen(filenamepath);
   if fid == -1
      error('Failed to open file %s for reading', filenamepath);
   end
   wholefile = fscanf(fid,'%c');
   status = fclose(fid);
   if status == -1
      warning('Failed to close file %s after reading', filenamepath);
   end
end

function rewritefile(filenamepath, wholefile)
%rewrite the file
   fid = fopen(filenamepath, 'wt');
   if fid == -1
      error('Failed to open file %s for writing', filenamepath);
   end
   fprintf(fid,'%c',wholefile); 
   status = fclose(fid);
   if status == -1
      warning('Failed to close file %s after writing', filenamepath);
   end
end

%% INPUT PARSER
function [name, library, project, whichparser] = parseinputs( ...
   name, funcname, varargin)

   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = funcname;
      parser.addRequired( 'funcname', @ischar);
      parser.addParameter('library', 'unsorted', @ischar);
      parser.addParameter('project', 'unsorted', @ischar);
      parser.addParameter('parser', 'MP', @ischar);
   end
   parser.parse(name, varargin{:});
   library = parser.Results.library;
   project = parser.Results.project;
   whichparser = parser.Results.parser;
   %inputs = p.Results.inputs;
   %outputs = p.Results.outputs;
end


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
   