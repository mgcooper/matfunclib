function wholefile = readprjjsonfile(jspath)
   fid = fopen([jspath 'functionSignatures.json']);
   wholefile = fscanf(fid,'%c');
   fclose(fid);
end