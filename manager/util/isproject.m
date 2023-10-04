function [tf, hasfolder] = isproject(projectname)
   %ISPROJECT Return true if projectname exists in the project directory.
   %
   %  [tf, hasfolder] = isproject(projectname) returns TF true if projectname is
   %  an entry in the projectdirectory, and HASFOLDER true if the project folder
   %  MATLABPROJECTPATH/projectname exists.
   %
   % See also

   tf = sum(getprjidx(projectname,readprjdirectory(getprjdirectorypath()))) ~= 0;

   hasfolder = isfolder(fullfile(getenv('MATLABPROJECTPATH'), projectname));
end