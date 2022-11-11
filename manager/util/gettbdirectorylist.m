function [list,sublist] = gettbdirectorylist

% Also see readtbdirectory ... that's how I get the list in the other functions

% note: I abandoned the sublist concept b/c some (perhaps most) toolboxes will
% have subfolders, so there isn't an obvious way to determine if the sub-folders
% are actually sub-libraries. the idea was to have a folder like stats/ that has
% several toolboxes underneath. Ahh ... I could rename them 'libXXX' and use
% that ... but for now, i just have to activate one entire toolbox at a time

tbpath = gettbsourcepath;
list = gettblist(tbpath);

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

list = string({list([list.isdir]).name}');

function list = gettblist(tbpath)
   list = dir(fullfile(tbpath));
   list = list([list.isdir]);
   list(strncmp({list.name}, '.', 1)) = []; 