function writetbjsonfile(jspath,wholefile)
   fid = fopen(fullfile(jspath,'functionSignatures.json'), 'wt');
   fprintf(fid,'%c',wholefile);
   fclose(fid);
end
