function [tf, hasfolder] = isproject(projectname, varargin)
   %ISPROJECT Return true if projectname exists in the project directory.
   %
   %  [tf, hasfolder] = isproject(projectname) returns TF true if projectname is
   %  an entry in the projectdirectory, and HASFOLDER true if the project folder
   %  that entry records exists.
   %
   %  tf = isproject(projectname, 'require_project_folder_exists') returns TF
   %  true only if projectname is an entry and its project folder exists.
   %
   % See also: istoolbox, getprojectfolder, verifyproject

   opts = optionParser({'require_project_folder_exists'}, varargin);

   tf = sum(getprjidx(projectname,readprjdirectory(getprjdirectorypath()))) ~= 0;

   % getprojectfolder reads the folder the entry records. A name with no entry
   % has no folder to test.
   hasfolder = tf && isfolder(getprojectfolder(projectname));

   if opts.require_project_folder_exists
      tf = hasfolder;
   end
end
