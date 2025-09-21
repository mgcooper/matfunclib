function [tf, hasfolder] = isproject(projectname)
   %ISPROJECT Return true if projectname exists in the project directory.
   %
   %  [tf, hasfolder] = isproject(projectname) returns TF true if projectname is
   %  an entry in the projectdirectory, and HASFOLDER true if the project folder
   %  MATLAB_PROJECT_PATH/projectname exists.
   %
   % See also: istoolbox

   tf = sum(getprjidx(projectname,readprjdirectory(getprjdirectorypath()))) ~= 0;

   hasfolder = isfolder(fullfile(getenv('MATLAB_PROJECT_PATH'), projectname));
end
