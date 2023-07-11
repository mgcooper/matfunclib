function varargout = lstoolboxes(varargin)
%LSTOOLBOXES list available toolboxes in MATLABSOURCEPATH
% 
% lstoolboxes() with no inputs lists all toolboxes in MATLABSOURCEPATH and
% active toolboxes in color
% 
% lstoolboxes(library) lists all sub-toolboxes in toolbox library LIBRARY
% 
% Example:
% 
% lstoolboxes('stats')
% 
% Matt Cooper

narginchk(0,1)

% turn on 'more' pager
cleanup = onCleanup(@()onCleanupFun());

% read the directory
tbdirectory = readtbdirectory;

% process sub-toolboxes
if nargin == 1
   library = validatetoolbox(varargin{1},mfilename,'library',1);
   tbnames = gettbdirectorylist(library);
   tbdirectory = tbdirectory(ismember(tbdirectory.name,tbnames),:);
   
   % this is the method that creates a dir struct for the sub-library, but for
   % this application, we want .active property, so we subset the full directory
   % as above 
   %tbdirectory = rmdotfolders(dir(fullfile(gettbsourcepath,library)));
end

more on
for n = 1:height(tbdirectory)
   if tbdirectory.active(n)
      fprintf(2,'%s%d: %s\n', '--> ', n, tbdirectory.name{n});
   else
      fprintf(1,'%s%d: %s\n', '    ', n, tbdirectory.name{n});
   end
end

% output, send back the list if requested
switch nargout
   case 1
      varargout{1} = tbdirectory;
end

function onCleanupFun
more off

function tbdirectory = processtbdirectory(tbdirectory,funcname,varargin)

if nargin < 3
   
   % return all top-level toolbox names
   tbnames = string(tbdirectory.name);
   
else

end




