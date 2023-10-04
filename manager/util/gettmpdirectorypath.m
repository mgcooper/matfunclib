function filename = gettmpdirectorypath
   [~,filename] = fileparts(tempname);
   filename = fullfile(getenv('PROJECTDIRECTORYPATH'),[filename '.mat']);
end