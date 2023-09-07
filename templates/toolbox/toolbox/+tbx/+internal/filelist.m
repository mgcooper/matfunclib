function varargout = filelist(foldername, opts)
%FILELIST list all files in folder and (optionally) subfolders
% 
% LIST = filelist(FOLDERNAME) returns a directory structure in the same
% format as DIR containing all files in directory FOLDERNAME
%
% LIST = filelist(FOLDERNAME, 'aspathlist', true) returns fullpaths to
% each file in a cell array rather than the default directory struct.
% 
% LIST = filelist(FOLDERNAME, 'aspathlist', true, 'asstring', true)
% returns a string array rather than cell array.
% 
% LIST = filelist(_, 'mfiles', true) only returns .m files.
% 
% LIST = filelist(_, 'subfolders', true) returns all files in all subfolders.
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
% 
% See also mfilename, mcallername, mfoldername, ismfile

arguments
   foldername (1,:) string = pwd() % fileparts(mfilename('fullpath'));
   opts.subfolders (1,1) logical = false;
   opts.asstruct (1,1) logical = true
   opts.aslist (1,1) logical = false
   opts.asstring (1,1) logical = false
   opts.fullpath (1,1) logical = false
   opts.mfiles (1,1) logical = false
end

% get all package folders
if opts.subfolders == true
   list = dir(fullfile(foldername, '**/*'));
else
   list = dir(fullfile(foldername));
end
list(strncmp({list.name}, '.', 1)) = [];
list = list(~[list.isdir]);

if opts.mfiles == true
   list = list(strncmp(reverse({list.name}), 'm.', 2));
   % list = list(cellfun(@ismfile, {list.name}));
end

if opts.aslist == true
   
   if opts.fullpath
      list = transpose(fullfile({list.folder},{list.name}));
   else
      list = transpose(fullfile({list.name}));
   end
   
   % convert to string array if requested
   if opts.asstring == true
      list = string(list);
   end
end

varargout{1} = list;

% % If we want to make this function 'mfilelist' then this would be used
% % list all items in top-level folder
% toplist = what(foldername);
% numfiles = numel(toplist.m);
% if numfiles == 0
   % fprintf('no mfiles found in %s\n', foldername)
   % varargout{1} = [];
   % return
% else
% end