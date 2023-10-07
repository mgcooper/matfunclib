function wholefile = readtbjsonfile(jspath)
   fid = fopen(fullfile(jspath,'functionSignatures.json'));
   wholefile = fscanf(fid,'%c');
   fclose(fid);
end