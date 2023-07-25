function list = gettbdirectorylist(varargin)
%GETTBDIRECTORYLIST get a list of toolbox directories 
%
%  list = gettbdirectorylist() returns the folder names in MATLABSOURCEPATH
%  list = gettbdirectorylist(TBNAME) returns sub-toolbox folder names, e.g.,
%  folder names in MATLABSOURCEPATH/TBNAME
% 
% See also readtbdirectory gettbnamelist

% gettbnamelist returns the names of toolboxes in the toolbox directory, so it
% should be used in functionsignatures for functions that work with valid
% toolboxes, whereas this function should be used in functions that operate on
% any folder in MATLABSOURCEPATH (e.g., addtoolbox)

if nargin < 1 % return all top-level toolboxes

   list = rmdotfolders(dir(gettbsourcepath)); % getenv('MATLABSOURCEPATH')
   list = string({list([list.isdir]).name}');

   % this could replace above, but getlist,getfilelist are fragile and need work
   % list = getfilelist(gettbsourcepath,'folders')

else
   library = validatetoolbox(varargin{1},mfilename,'library',1);

   % this creates a tbdirectory for the sublib:
   tblist = rmdotfolders(dir(fullfile(gettbsourcepath,library)));
   
   % and this would complete the conversion to tbname
   list = string({tblist([tblist.isdir]).name}');
   
   % and like above, this could replace two above
   % list = getfilelist(fullfile(gettbsourcepath,library),'filenames');

   % and this is another method that uses tbdirectory.source:
   %    sublibs = strrep(fileparts(tbdirectory.source), ...
   %       strcat(getenv('MATLABSOURCEPATH'),filesep),'');
   %    validatestring(varargin{1},sublibs,funcname,'sublib',1);
   %    requestedlib = ismember(varargin{1},sublibs);

end