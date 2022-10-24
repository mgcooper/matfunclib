function [latestfile,filedate] = getlatestfile(directory)
%This function returns the latest file from the directory passsed as input
%argument

%Get the directory contents
dirc = dir(directory);

%Filter out all the folders.
dirc = dirc(find(~cellfun(@isfolder,{dirc(:).name})));

%I contains the index to the biggest number which is the latest file
[~,I] = max([dirc(:).datenum]);

if ~isempty(I)
    latestfile = dirc(I).name;
    filedate = dirc(I).date(1:11);
end

end