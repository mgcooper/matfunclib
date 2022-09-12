function tbpath = gettbsourcepath(tbname)
   tbpath = [getenv('MATLABSOURCEPATH') tbname '/'];
   