function projlist = setprojectfiles(projectname,filelist)
%SETPROJECTFILES save the list of open project files
% 
% 
% Example
% 
% I want to update the paths in the activefiles list of a project:
% 
% oldstr = 'E3SM-MOSART-offline-mode';
% newstr = 'interface-e3sm';
% projectlist = openprojectdirectory;  
% files = projectlist.activefiles{48,1};
% files = strrepl(files, oldstr, newstr);
% setprojectfiles("interface-e3sm", files)
% 
% See also getprojectfiles

% Bit more detail on the example. I wanted to rename e3sm-interface to
% interface-e3sm, but I don't think there is a 'renameproject' function, so I
% first removed it, b/c it had no activefiles, then changed the actual dirname
% to interface-e3sm, then used addproject, but the active files were the ones
% associated with 'interface' which were all in E3SM-MOSART-offline-mode dir, so
% I needed to replace those paths with interface-e3sm, below did it, I made it a
% general purpose function strrepl, but it is useful for resetting project paths


narginchk(0,2);

if nargin < 1
   projectname = getactiveproject();
end

% read the project list
projlist = readprjdirectory();
projindx = getprjidx(projectname,projlist);

% if a file list is provided, use it, otherwise get all open files
if nargin <= 1
   projlist.activefiles{projindx} = getopenfiles();
elseif nargin == 2
   projlist.activefiles{projindx} = filelist;
end

writeprjdirectory(projlist);

% I had this note: Shouldn't need these with setprojectfolder but in case:
% setprojectfiles
% setactivefiles
% not sure what I was thinking or if I missed something like maybe if
% setprojectfolder is used then the projectfiles are just the ones in that path,
% but activefiles could be antyhing

% careful with passing projlist around. if we always read/write, then we know
% its state is up to date, but if we pass it around, it can get out of sync. an
% older version of workon made a variable copy of projlist before calling this
% function, then passed the variable copy to setprojectactive which rewrote the
% directory and erased the saved active files. I commented this out for that
% reason and removed projlist as an input.

% if nargin == 1
%    projlist = readprjdirectory;
% end
% projindx = getprjidx(projname,projlist);