function tbidx = findtbentry(toolboxes,tbname)
% need to make toolboxes secondarg and load directory if nargin==1
% also rename gettbentry or gettbindex
tbidx = ismember(lower(toolboxes.name),lower(tbname));