function wholefile = readtbjsonfile(jspath)
   jsfile      = [jspath 'functionSignatures.json'];
   fid         = fopen(jsfile);
   wholefile   = fscanf(fid,'%c');     fclose(fid);