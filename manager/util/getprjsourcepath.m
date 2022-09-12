function prjpath = getprjsourcepath(prjname)
   if nargin == 0
      prjpath = getenv('MATLABPROJECTPATH');
   else
      prjpath = [getenv('MATLABPROJECTPATH') prjname '/'];
   end
   