function projects = readprjdirectory(prjpath)
if nargin == 0
   prjpath = getprjdirectorypath;
end
projects = readtable(prjpath,'Delimiter',',','ReadVariableNames',true);