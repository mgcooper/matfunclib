function setprojectfiles(projectname)
%SETPROJECTFILES save the list of open project files
% 
% 
% See also getprojectfiles

projlist = readprjdirectory();
projindx = getprjidx(projectname,projlist);
projlist.activefiles{projindx} = getopenfiles();
writeprjdirectory(projlist);


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