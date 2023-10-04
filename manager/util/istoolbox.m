function [tf, hasfolder] = istoolbox(tbxname)
   %ISTOOLBOX Return true if TBXNAME exists in the toolbox directory.
   %
   %  [tf, hasfolder] = istoolbox(tbxname) returns TF = TRUE if TBXNAME is an
   %  entry in the toolbox directory, and HASFOLDER = TRUE if the toolbox folder
   %  MATLABSOURCEPATH/tbxname exists.
   %
   % See also isproject

   tf = sum(findtbentry(readtbdirectory(gettbdirectorypath),tbxname)) > 0;

   hasfolder = isfolder(fullfile(getenv('MATLABSOURCEPATH'), tbxname));
end
