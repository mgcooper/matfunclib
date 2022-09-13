function buildfunclibjsonfile
   
   % note: need to use this to build a function directory that has the
   % folder names and function names for use with mkfunction etc.
   
   % this requires a template is ready with a particular format:
   funcdir     = getenv('MATLABFUNCTIONPATH');
   templatedir = getenv('MATLABTEMPLATEPATH');
   jsfile      = [templatedir 'functionSignatures.funclibtemplate.json'];
   
   % get a list of all .m files in the function path and all sub dirs
   filelist    = dir(fullfile(funcdir, '**/*.m')); 
   
   % create a character list to add to the json
   funclist    = buildfunclibjsonlist(filelist);
   
   % read in the json template and add the project list
   fid         = fopen(jsfile);
   wholefile   = fscanf(fid,'%c');     fclose(fid);
        
   % replace the most recent entry with itself + the new one
   wholefile   = strrep(wholefile,'choices={}',funclist);
   
   % write it over again, this time to the 'workon' folder
   jsfile      = [funcdir 'libsys/functionSignatures.json'];
   fid         = fopen(jsfile, 'wt');
   
   fprintf(fid,'%c',wholefile); fclose(fid);
   
   
end
   
function list = buildfunclibjsonlist(filelist)
   
   numfiles = numel(filelist);
   list     = 'choices={''';

   excludelist    = {'readme','_test','test_','_bk','bk_,','_archive',  ...
                     'archive_','_tmp','tmp_','_old','old_','_todo',    ...
                     'todo_','_v0','_v1','_v2','_v3','_bad','bad_',     ...
                     '_edit','edit_','_example','example_','_ex','ex_', ...
                     '_backup','backup_','_examples','example_',        ...
                     '_working','working_','_notes','notes_','_check',  ...
                     'check_'};
      
   completedlist  = "";
   
   for n = 1:numfiles
      
      funcname = strrep(filelist(n).name,'.m','');
      
      if any(ismember(excludelist,funcname))
         continue
      end
      
      % check for duplicates
      if any(ismember(completedlist,string(funcname)))
         continue
      end
      
      if n == 1
         list = [list funcname ''','];
      elseif n == numfiles
         list = [list '''' funcname '''}'];
      else
         list = [list '''' funcname ''','];
      end
      
      completedlist  = [completedlist funcname];
      
   end
end