function list = listallmfunctions
%LISTALLMFUNCTIONS list all .m files in MATLABFUNCTIONPATH
% 
%  LIST = listallmfunctions() returns all .m files in MATLABFUNCTIONPATH in a
%  cell array LIST
% 
% 
% See also mfunctionlist, makemfunctionlist

if ~isenv('MATLABFUNCTIONPATH')
   error('set environment variable MATLABFUNCTIONPATH to use this function')

elseif isenv('FEXFUNCTIONPATH')
   if isenv('MATLABPROJECTPATH')
      plist = {'MATLABFUNCTIONPATH','FEXFUNCTIONPATH','MATLABPROJECTPATH'};
   else
      plist = {'MATLABFUNCTIONPATH','FEXFUNCTIONPATH'};
   end
end

% this includes all projects but makes tab completion much slower b/c it
% recurses through all subdirectories which includes scripts. the custom check
% if n == 3 speeds it up enough to be tolerable.
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
