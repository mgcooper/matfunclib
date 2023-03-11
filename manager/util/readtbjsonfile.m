function wholefile = readtbjsonfile(jspath)
jsfile = fullfile(jspath,'functionSignatures.json');
fid = fopen(jsfile);
wholefile = fscanf(fid,'%c');     
fclose(fid);