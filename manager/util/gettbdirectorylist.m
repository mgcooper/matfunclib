function [list,sublist] = gettbdirectorylist

% Also see readtbdirectory

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


tbpath = gettbsourcepath;
list = gettblist(tbpath);

% % % % % % % % % % % % 
% sublist loop was here
% % % % % % % % % % % % 

list = string({list([list.isdir]).name}');

function list = gettblist(tbpath)
list = dir(fullfile(tbpath));
list = list([list.isdir]);
list(strncmp({list.name}, '.', 1)) = []; 
   
   
   
   
   
% note: I abandoned the sublist concept b/c some (perhaps most) toolboxes will
% have subfolders, so there isn't an obvious way to determine if the sub-folders
% are actually sub-libraries. the idea was to have a folder like stats/ that has
% several toolboxes underneath. Ahh ... I could rename them 'libXXX' and use
% that ... but for now, i just have to activate one entire toolbox at a time

% % update: here I am defining some folders:
% validlibs = {'stats','hydro','climate','plotting','physics','numericalmethods',...
%    'manager','spatial','data'};
% % will need to update anything that uses this to deal with subfolders

% for n = 1:numel(list)
%    subpath  = [tbpath list(n).name];
%    sub_n    = gettblist(subpath);
%    
%    % if there is more than one subfolder, assume these are sub-libraries
%    if numel(sub_n)>1
%    end
%    
% % %    this does what gettblist does but is here for testing
% %    sub_n = dir(fullfile(subpath));
% %    sub_n = sub_n([sub_n.isdir]);
% %    sub_n(strncmp({sub_n.name}, '.', 1)) = []; 
% end