function rmproject(projectname,varargin)
%RMPROJECT general description of function
%
%  RMPROJECT(projectname) removes the row for the project with name projectname
%  from the project directory list.
%
% Example
% 
% rmproject('interface')
% 
% After adding interface-e3sm and setting the activefiles using setprojectfiles
% (see example there), I switched to interface-e3sm then removed the old
% interface (which was linked to E3SM-Offline-Mode):
%
% Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
%
% See also: mkproject, workon, workoff

% input parsing
[projectname, keepsource] = parseinputs(mfilename, projectname, varargin{:});

% main function
projlist = readprjdirectory();
projindx = getprjidx(projectname,projlist);

% check if the requested project is the activeproject
wasactive = false;
if any(projlist.activeproject(getprjidx(projectname)) == true)
   wasactive = true;
end

% remove the project from the directory (does not delete the actual files)
projlist(projindx,:) = [];

if wasactive
   projlist.activeproject(1:end) = false;
   projlist.activeproject(ismember(projlist.name,'default')) = true;
   setenv('MATLABACTIVEPROJECT','default');
end

if ~keepsource
   % TODO: option to remove the directory
end

% final step
writeprjdirectory(projlist);

%% INPUT PARSER
function [projectname, keepsource] = parseinputs(funcname, projectname, varargin);

parser = inputParser;
parser.FunctionName = funcname;
parser.addRequired('projectname', @ischar);
parser.addParameter('keepsource', true, @islogical);
parser.parse(projectname,varargin{:});

projectname = parser.Results.projectname;
keepsource = parser.Results.keepsource;