function list = listallmfunctions

% this includes all projects but makes tab completion much slower b/c it
% recurses through all subdirectories which includes scripts. the custom check
% if n == 3 speeds it up enough to be tolerable.
plist = {'MATLABFUNCTIONPATH','FEXFUNCTIONPATH','MATLABPROJECTPATH'};
% plist = {'MATLABFUNCTIONPATH','FEXFUNCTIONPATH'};
list = {};
for n = 1:numel(plist)
   path_n = getenv(plist{n});
   if n == 3
      % need a list of all projects then cycle through
      projlist = cellstr(projectdirectorylist);
      for m = 1:numel(projlist)
         path_m = fullfile(path_n,projlist{m},'functions');
         list_m = getfunclist(path_m);
         list = [list {list_m.name}];
      end
   else
      list_n = getfunclist(path_n);
      list = [list {list_n.name}];
   end
end
list = unique(list);

function list = getfunclist(funcpath)
list = getlist(funcpath,'*m','subdirs',true);
list = list(~contains({list.name},'readme'));

%% THIS was the original method but only the first two paths
% % not using a loop is not faster
% list1 = getlist(getenv('MATLABFUNCTIONPATH'),'*m','subdirs',true);
% list2 = getlist(getenv('FEXFUNCTIONPATH'),'*m','subdirs',true);
% list3 = getlist(getenv('MATLABPROJECTPATH'),'*m','subdirs',true);
% list1 = list1(~contains({list1.name},'readme'));
% list2 = list2(~contains({list2.name},'readme'));
% list3 = list3(~contains({list3.name},'readme'));
% list = [{list1.name} {list2.name} {list3.name}];