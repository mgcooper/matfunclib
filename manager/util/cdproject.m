function cdproject(projectname)
if nargin == 0
   projectname = getactiveproject;
end
% cd(getprjsourcepath(projectname));
cd(getprojectfolder(projectname));