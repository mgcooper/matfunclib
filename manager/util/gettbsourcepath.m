function tbpath = gettbsourcepath(tbname)
   if nargin == 0
      tbpath = getenv('MATLABSOURCEPATH');
   else
      tbpath = [getenv('MATLABSOURCEPATH') tbname '/'];
   end
   