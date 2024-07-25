function tout = decimalday2datetime(decimaldays,yy)
   %DECIMALDAY2DATETIME Converts an array of decimal days to a maltab datetime object

   ti = decimaldays(1);
   di = floor(ti);
   hi = mod(ti,1)*24;
   mi = mod(hi,1)*60;
   si = mod(mi,1)*60;
   hi = floor(hi);
   mi = floor(mi);
   si = floor(si);

   tf = decimaldays(end);
   df = floor(tf);
   hf = mod(tf,1)*24;
   mf = mod(hf,1)*60;
   sf = mod(mf,1)*60;
   hf = floor(hf);
   mf = floor(mf);
   sf = floor(sf);

   % get the mmm and dd from the doy
   t1 = datetime(yy,1,1,0,0,0);
   t2 = datetime(yy,12,31,0,0,0);
   tt = t1:t2;

   mmi = tt.Month(di);
   ddi = tt.Day(di);

   t1 = datetime(yy,mmi,ddi,hi,mi,si);
   tout = t1+(decimaldays - ti);
end
