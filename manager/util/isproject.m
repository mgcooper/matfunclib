function tf = isproject(projectname)

tf = sum(getprjidx(projectname,readprjdirectory(getprjdirectorypath()))) ~= 0;