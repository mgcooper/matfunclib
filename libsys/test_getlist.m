clean

cdfunc('cdfunc')

dirname = fullfile(pwd);
dirlist = dir(dirname);

%% use getfilelist with the path

% getfilelist accepts required dirname and optional pattern
l1 = getfilelist(dirname);
l2 = getfilelist(dirname,'.m');

%% use getlist with the path

% getlist accepts required dirname and pattern and optional 
l3 = getlist(dirname,'.m');
l4 = getlist(dirname,'.m','asfiles',true);

% for l4, getlist calls: 
% list = fnamefromlist(list,'asstring');
% see next

%% use fnamefromlist with dirlist

% test the optionParser version with optional fileindex
fnamefromlist(dirlist,'asstring')

% test the optionParser version with required fileindex
% fnamefromlist(dirlist,[],'asstring')

% test the magicParser version
% fnamefromlist(dirlist,'asstring',true);

