function list = gettbdirectorylist(varargin)
%
% See also readtbdirectory tbdirectorylist

% UPDATE 11 april 2023, not sure if i overlooked the tbdirectorylist function
% but that one returns the toolbox names only, can be used in functionsignatures

% NOTE: sub-toolboxes are supported. the key thing is that all I need is the
% top level list in mysource/ and addtoolbox has the option to nest inside those
% top-level folders. So if I donwload a code base and put it in 'stats' or
% 'hydro', say the 'crest' model, I do: addtoolbox('crest','hydro') and
% addtoolbox adds the path to mysource/hydro/crest to the tbdirectory, so here I
% just read that directory and it's already correct. I think the tricky thing
% would be if I used dir(fullfile type approach to get libs, which I think is
% how its done in addproject. SO THAT MEANS there may be a usecase for keeping a
% spreadsheet-style directory ratehr than wha tI thought was the bettter method
% in addproject

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