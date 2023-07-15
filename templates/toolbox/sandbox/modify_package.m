clean

% I gave up on this and just copied/pasted the line 

dryrun = false;

% the script assumes you are in the package folder where the code is saved
% cd('+bfra/');

% strings to find and replace
str_find1 = '% Matt Cooper';
str_find2 = '% parse inputs';
str_find3 = '% input parsing';

str_repl1 = {'% if called with no input, open this file', ...
   'if nargin == 0; open(mfilename(''fullpath'')); return; end'};


str_repl2 = 'if nargin == 0; open(mfilename(''fullpath'')); return; end';

% filelist
list = dir(fullfile('*.m'));
list(strncmp({list.name}, '.', 1)) = [];

for n = 1:numel(list)
   
   funcname = list(n).name;
   filename = fullfile(pwd,funcname);
   fid = fopen(filename,'r');
   
   % read in the function to a char
   wholefile = fscanf(fid,'%c');     %fclose(fid);

   frewind(fid)

   % check for a parse inputs line
   found1 = contains(wholefile,'% Matt Cooper');
   found2 = contains(wholefile,'% parse inputs');
   found3 = contains(wholefile,'% input parsing');

   if found1
      if dryrun == true
         % move to temp folder
         copyfile(filename,fullfile(pwd,'temp',funcname));
         bfra.util.repline(fullfile(pwd,'temp',funcname),str_find1,str_repl1,'appendblanks')
      else
         % copyfile(filename,fullfile(pwd,'temp',funcname)); % backup to test
         bfra.util.repline(filename,str_find1,str_repl1,'appendblanks')
      end
   end
  % fclose(fid); % it's closed in repline
end