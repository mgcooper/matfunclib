function allFiles = listallfiles(parentFolders)
% 
% 

% Note: see tbx.internal.filelist, reconcile all other 'getlist' type functions
% with that one

% If parentFolders is a struct of directory structs, convert to 

% If parentFolders is char or string, convert to cell array
if ischar(parentFolders) || isstring(parentFolders)
    parentFolders = cellstr(parentFolders);
end

% Find all files in each folder
allFilesCellArray = cellfun(@(folder) ...
   rmdotfolders(dir(fullfile(folder, '**/*'))), parentFolders, 'Un', false);

% Combine all arrays into a single array
allFiles = vertcat(allFilesCellArray{:});

% Filter out subfolders
allFiles = allFiles(~[allFiles.isdir]);

% Convert to full paths
allFiles = fullfile({allFiles.folder}',{allFiles.name}');

end
