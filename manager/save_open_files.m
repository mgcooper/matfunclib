function filelist = save_open_files

    
openfiles   = matlab.desktop.editor.getAll;
filelist    = string({openfiles.Filename});
filelist    = filelist(:);

fsave       = setpath(['open_tabs/matlab_editor/open_' date '.mat']);

if exist(fsave,'file')
    n       = 1;
    fsave   = [strrep(fsave,'.mat','') '_' num2str(n) '.mat'];
    
    while exist(fsave,'file')
        n       = n+1;
        fsave   = strrep(fsave,num2str(n-1),num2str(n));
    end

end
save(fsave,'filelist');
cd(setpath('open_tabs/matlab_editor/'));