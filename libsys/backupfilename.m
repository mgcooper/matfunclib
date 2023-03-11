function fname_bk = backupfilename(fname)

% back up an existing file
if isfile(fname)
   [~,~,fext] = fileparts(fname);
   fname_bk = strrep(fname,fext,['_bk_' date fext]);
   n = 1;
   while isfile(fname_bk)
      fname_bk = strrep(fname,fext,['_bk_' date '_' num2str(n) fext]);
      n = n+1;
   end
   % copyfile(fname,fname_bk)
end