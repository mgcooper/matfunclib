function tbname = validatetoolbox(tbname,funcname,argname,argnum)
tblist = gettbdirectorylist;
tbname = validatestring(tbname,tblist,funcname,argname,argnum);
