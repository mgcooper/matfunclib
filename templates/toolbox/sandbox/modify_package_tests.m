clean

% i saed this _tests version just to see what didn't work

% I gave up on this and just copied/pasted the line 

dryrun = true;

% the script assumes you are in the package folder where the code is saved
% cd('+bfra/');

% strings to find and replace
str_find1 = '% parse inputs';
str_find2 = '% Matt Cooper';
str_find3 = '% input parsing';
str_repl1 = ...
   ['\nif nargin == 0; open(mfilename(''fullpath'')); return; end \n\n' ...
   '%% parse inputs;'];

% str_repl2 = ...
%    '\nif nargin == 0; open(mfilename(''fullpath'')); return; end \n';

% str_repl2 = [ newline ...
%    'if nargin == 0; open(mfilename(''fullpath'')); return; end                      '];

str_repl2 = 'if nargin == 0; open(mfilename(''fullpath'')); return; end';

fprintf(str_repl2)

% filelist
list = dir(fullfile('*.m'));
list(strncmp({list.name}, '.', 1)) = [];

n=7

for n = 1:numel(list)
   
   funcname = list(n).name;
   filename = fullfile(pwd,funcname);
   fid = fopen(filename,'rt');
   
   % read in the function to a char
   wholefile   = fscanf(fid,'%c');     %fclose(fid);

   frewind(fid)

   % check for a parse inputs line
   found1 = contains(wholefile,'% parse inputs');
   found2 = contains(wholefile,'% Matt Cooper');
   found3 = contains(wholefile,'% input parsing');
   

   if found2

      linenumber = 0;
      while true
        thisline = fgetl(fid);
        linenumber = linenumber+1;
        if contains(thisline,str_find2 ); break; end
        if ~ischar(thisline); break; end  % end of file
      end
   
      % for str_find2, advance forward one line
      thisline = fgetl(fid);
      linenumber = linenumber+1;

      fclose(fid);

      % if the next line is blank, insert the replacement
      if isempty(thisline)
      
%          % close the file and reopen with write permission
%          fclose(fid);
%          fid = fopen(funcname,'r+');

         % fprintf('%s',str_repl2)

         replaceFileLine(filename,linenumber,str_repl2);


         replaceFileLine(filename,linenumber,newline);
         

         % use fseek to place the position
         fseek(fid, 0, 'cof');

         if dryrun == false
            % fid = fopen(funcname, 'wt');
            % fprintf(fid,'%c',wholefile); fclose(fid);
         end

         % Print the new values
         fprintf(fid, str_repl2);

         

         replaceFileLine(funcname,replaceLine,fileLine)

         % first rewind 
         wholefile = strrep(wholefile,thisline,str_repl2);
      end
   end

  fclose(fid);


   % read in the function line and the H1 line
   firstline   = fgetl(fid);
   secondline  = fgetl(fid);
   frewind(fid)
   
   
   
   
   % STEP 2: FUNCTION DEFINITION LINE (FIRST LINE)
   % ---------------------------------------------
   
   % strip the old BFRA_ prefix from the function definition line
   if contains(firstline,str_find1)
      
      % remove BFRA_ from the first line
      newline = strrep(firstline,str_find1,'');
      
      % replace the first line in the whole file
      wholefile = strrep(wholefile,firstline,newline);
   
   % strip the old bfra_ prefix from the function definition line
   elseif contains(firstline,old_pfx_lc)
      
      % remove bfra_ from the first line
      newline = strrep(firstline,old_pfx_lc,'');
   
      % replace the first line in the whole file
      wholefile = strrep(wholefile,firstline,newline);
   
   end
   
   % STEP 3: H1 LINE (SECOND LINE)
   % --------------------------------
   if contains(secondline,str_find1)
      
      % remove BFRA_ from the second line
      newsecondline = strrep(secondline,str_find1,'');
      
      % replace the second line in the whole file
      wholefile = strrep(wholefile,secondline,newsecondline);
   
   elseif contains(secondline,old_pfx_lc)
      
      % remove bfra_ from the second line
      newsecondline = strrep(secondline,old_pfx_lc,'');
   
      % replace the second line in the whole file
      wholefile = strrep(wholefile,secondline,newsecondline);
   
   end
   
   % STEP 4: REPLACE FUNCTION CALLS USING NEW PKG. PREFIX
   % -----------------------------------------------------
   
   % now that the function definition line and H1 line have been replaced,
   % replace all other occurrences of BFRA_ and bfra_ with bfra., which includes
   % the inputParser, See also lines, and general function calls.
   
   % do the lower case prefix bfra_
   if contains(wholefile,old_pfx_lc)
      
      wholefile = strrep(wholefile,old_pfx_lc,str_repl1);
      
   end
   
   % do the upper case prefix BFRA_
   if contains(wholefile,str_find1)
      
      wholefile = strrep(wholefile,str_find1,str_repl1);

   end
   
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % REWRITE THE FILE (DANGER ZONE)
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   if dryrun == false
      fid = fopen(funcname, 'wt');
      fprintf(fid,'%c',wholefile); fclose(fid);
   end
   
end