function copysetuptemplate(destpath)
   %COPYSETUPTEMPLATE Copy the setuptemplate.m file to destination.
   %
   % COPYSETUPTEMPLATE() Copies setuptemplate.m to pwd()
   % COPYSETUPTEMPLATE(DEST) Copies setuptemplate.m to DEST
   % 
   % See also:

   if nargin < 1
      destpath = pwd;
   end
   src = fullfile(getenv('MATLABTEMPLATEPATH'),'setuptemplate.m');
   dst = fullfile(destpath,'Setup.m');

   copyfile(src,dst);
end
