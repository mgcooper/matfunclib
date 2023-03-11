function [latestfile,filedate] = getlatestfile(directory,n)
%GETLATESTFILE get the nth most recent file in directory, default n=1
% 
% Syntax
%  [latestfile,filedate] = getlatestfile(directory,n) returns the latest file
%  from the directory passsed as input argument, or the nth-latest file if a
%  second input is provided  
% 
% See also

% Updates
% 22 Feb 2023 added second input argument to return nth most recent file

if nargin < 2
   n = 1;
end

%Get the directory contents
dirc = dir(directory);

%Filter out all the folders.
dirc = struct2table(dirc(~cellfun(@isfolder,{dirc(:).name})));

%Sort by date
dirc = sortrows(dirc,'datenum','descend');

% return the requested file
if height(dirc)>=n
   latestfile = dirc.name(n);
   filedate = datetime(dirc.date(n));
end

%I contains the index to the biggest number which is the latest file
% [~,I] = max([dirc(:).datenum]);
% 
% if ~isempty(I)
%     latestfile = dirc(I).name;
%     filedate = dirc(I).date(1:11);
% end