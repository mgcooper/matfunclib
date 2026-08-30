function filename = gettmpdirectorypath
   [~,filename] = fileparts(tempname);
   filename = fullfile(getenv('MATLAB_DIRECTORY_PATH'),[filename '.mat']);
end