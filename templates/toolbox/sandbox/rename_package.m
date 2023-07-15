
% This script was developed to convert an existing code base to a package. The
% script does four things: 
% 
% 1) it renames the existing functions using a system call to git mv
% 2) it replaces the old function names on the function definition line with the new function names
% 3) it replaces the old function names on the H1 line with the new function names
% 4) it replaces all occurences of function calls within the package functions
% with new function calls that include the package prefix with dot notation, as
% required to call functions contained within a package namespace.
% 
% The first step was required because functions in the original codebase were
% named using a consistent prefix (more on this below). I needed to strip this
% prefix off each function name, meaning the functions had to be renamed, the
% so the call to git mv was necessary to preserve source control history (but
% wouldn't be if you aren't using source control). Therefore the second and
% third steps were also needed since my functions were renamed.
% 
% The fourth step could also be accomplished by adding an import pkg.* statement
% at the top of each function, rather than appending the pkg. prefix to each
% function call, but I opted for the latter.
% 
% In the original codebase, function names were prefixed with a consistent
% acronym, but two types of functions were distinguished by using UPPERCASE vs
% lowercase prefix: bfra_ and BFRA_. Therefore, in the code below, I had to
% find/replace these two prefixes separately. In the new pkg, this distinction
% isn't used so I replace all of them with the new +bfra prefix. 
% 
% The reason this remains a script rather than a function is because it is
% nowhere near general purpose, so make sure you understand what it does before
% you run it on your package!
% 
% Matt Cooper, guycooper (a) ucla dot edu , feel free to reach out with
% questions.

% if true, files will not be overridden. add disp/sprintf etc. to the code as
% needed to dry run it first
dryrun = true;

% the script assumes you are in the package folder where the code is saved
cd('/path/to/DescriptiveProjectName/+pkg/');

% my project used the acronym 'bfra_' and 'BFRA_' on all functions. The new
% function calls need to be appended with 'bfra.'
old_pfx_UC = 'BFRA_';
old_pfx_lc = 'bfra_';
new_pfx    = 'bfra.'; 


% -----------------------------------------------------------------------------
% PART 1 - STRIP THE CURRENT PROJECT PREFIX FROM ALL FUNCTION FILE NAMES, THEN
% GIT MV THE OLD FILES TO THE NEW FILES
% -----------------------------------------------------------------------------
list = dir(fullfile('*.m'));
list(strncmp({list.name}, '.', 1)) = []; 

% could use this if you have sub-folders and want to loop over them
% outerlist = list([list.isdir]); 

for n = 1:numel(list)
   
   oldfuncname = list(n).name;
   
   % strip the BFRA_ prefix
   if contains(oldfuncname,old_pfx_UC)
      
      newfuncname = strrep(oldfuncname,old_pfx_UC,'');
      
   % strip the bfra_ prefix
   elseif contains(oldfuncname,old_pfx_lc)
      
      newfuncname = strrep(oldfuncname,old_pfx_lc,'');
      
   % some functions didn't have a prefix
   else
      continue
   end
   
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % MOVE THE FILE using git mv (DANGER ZONE)
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   if dryrun == false
      system(['git mv ' oldfuncname ' ' newfuncname])
   end
   
end

% -----------------------------------------------------------------------------
% PART 2 - OPEN ALL THE FILES AND REMOVE BFRA_ FROM THE FUNCTION CALLS
% WITHIN EACH FUNCTION, AND FROM THE H1 LINE AND INPUT PARSER TOO
% -----------------------------------------------------------------------------

% rebuild the list
list = dir(fullfile('*.m'));
list(strncmp({list.name}, '.', 1)) = []; 

for n = 1:numel(list)
   
   funcname    = list(n).name;
   fid         = fopen(funcname);
   
   % read in the function line and the H1 line
   firstline   = fgetl(fid);
   secondline  = fgetl(fid);
   frewind(fid)
   
   % read in the function to a char
   wholefile   = fscanf(fid,'%c');     fclose(fid);
   
   
   % STEP 2: FUNCTION DEFINITION LINE (FIRST LINE)
   % ---------------------------------------------
   
   % strip the old BFRA_ prefix from the function definition line
   if contains(firstline,old_pfx_UC)
      
      % remove BFRA_ from the first line
      newfirstline = strrep(firstline,old_pfx_UC,'');
      
      % replace the first line in the whole file
      wholefile = strrep(wholefile,firstline,newfirstline);
   
   % strip the old bfra_ prefix from the function definition line
   elseif contains(firstline,old_pfx_lc)
      
      % remove bfra_ from the first line
      newfirstline = strrep(firstline,old_pfx_lc,'');
   
      % replace the first line in the whole file
      wholefile = strrep(wholefile,firstline,newfirstline);
   
   end
   
   % STEP 3: H1 LINE (SECOND LINE)
   % --------------------------------
   if contains(secondline,old_pfx_UC)
      
      % remove BFRA_ from the second line
      newsecondline = strrep(secondline,old_pfx_UC,'');
      
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
      
      wholefile = strrep(wholefile,old_pfx_lc,new_pfx);
      
   end
   
   % do the upper case prefix BFRA_
   if contains(wholefile,old_pfx_UC)
      
      wholefile = strrep(wholefile,old_pfx_UC,new_pfx);

   end
   
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   % REWRITE THE FILE (DANGER ZONE)
   % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   if dryrun == false
      fid = fopen(funcname, 'wt');
      fprintf(fid,'%c',wholefile); fclose(fid);
   end
   
end