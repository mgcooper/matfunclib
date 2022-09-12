
%parse XML file
xmlFiles    = xmlread([prefdir filesep 'MATLAB_Editor_State.xml']);
%Retrieve the "clients"
FileNodes   = xmlFiles.getElementsByTagName('File');
%get the length of the FileNodes
nrFiles     = FileNodes.getLength;
%initialize Files
Files       = cell(nrFiles,1);
%initialize isFile
isFile      = zeros(nrFiles,1);
%Iterate over all Elements and check if it is a file.
for iNode = 0:nrFiles-1 % Java indexing.
    %Files
    Files{iNode+1} = [char(FileNodes.item(iNode).getAttribute('absPath')),...
        filesep,char(FileNodes.item(iNode).getAttribute('name'))];
    %check if the "client" is a file:
    isFile(iNode+1) = exist(Files{iNode+1},'file') == 2 && ~(strcmp(Files{iNode+1},'Workspace'));
end
%remove the other files:
MyFiles = Files(find(isFile));
%open the files in the editor:
edit(MyFiles{:});