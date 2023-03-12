function projlist = setprojectfiles(projectname,filelist)
%SETPROJECTFILES save the list of open project files
% 
% 
% See also getprojectfiles
narginchk(0,2);

if nargin < 1
   projectname = getactiveproject();
end

% read the project list
projlist = readprjdirectory();
projindx = getprjidx(projectname,projlist);

% if a file list is provided, use it, otherwise get all open files
if nargin == 1
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