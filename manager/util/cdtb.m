function cdtb(tbname)
   if nargin<1
      cd(gettbsourcepath());
   else
      cd(gettbsourcepath(tbname));
   end
end
