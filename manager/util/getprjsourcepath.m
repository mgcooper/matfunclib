function projpath = getprjsourcepath(projectname)
%GETPRJSOURCEPATH get path to root of project

% note: should rename to getprojectpath
% update: getprjsourcpath is more like 'buildprjsourcepath' - it builds the
% path, it doesn't check if it already exists, like I do with any(ismember) in
% addproject and other functions. For example, the comment below is from
% addproject, the point is that this function assumes all projects are in the
% MATLABPROJECTPATH whereas my new method reads the directory, but that might
% actually be worse b/c it requires always reading and writing so ultimatley i
% shoudl go back to this method and enforce one project diretry top level. 
% 21 Mar 2023, commented this out b/c it uses the project directory whcih wont
% have the project if its being added
% projpath = getprjsourcepath(projname); % get the full path to the project

if nargin == 0
   projpath = getenv('MATLABPROJECTPATH');
else
   projlist = readprjdirectory;
   projindx = ismember(projlist.name,projectname);
   projpath = fullfile(projlist.folder{projindx},projectname);
end

   
% % deprecated by new method that reads the folder in the project directory
%    if nargin == 0
%       prjpath = getenv('MATLABPROJECTPATH');
%    else
%       prjpath = [getenv('MATLABPROJECTPATH') prjname '/'];
%    end
   