function writeprjjsonfile(jspath,wholefile)
   jsfile      = [jspath 'functionSignatures.json'];
   fid         = fopen(jsfile, 'wt');
   fprintf(fid,'%c',wholefile); fclose(fid);