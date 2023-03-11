function writetbjsonfile(jspath,wholefile)
jsfile      = fullfile(jspath,'functionSignatures.json');
fid         = fopen(jsfile, 'wt');
fprintf(fid,'%c',wholefile); fclose(fid);