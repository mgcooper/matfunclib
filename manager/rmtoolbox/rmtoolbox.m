function toolboxes = rmtoolbox(tbname,varargin)
%RMTOOLBOX removes toolbox from toolboxdir (optional: delete the toolbox)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'rmtoolbox';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   addRequired(p, 'tbname',@(x)ischar(x));
   addParameter(p,'removesource',false,@(x)islogical(x));

   parse(p,tbname,varargin{:});
   tbname         = p.Results.tbname;
   removesource   = p.Results.removesource;  
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   
% read in the toolbox directory and find the entry for this toolbox
   dbpath      = gettbdirectorypath;
   toolboxes   = readtbdirectory(dbpath);
   tbidx       = findtbentry(toolboxes,tbname);
   tbpath      = gettbsourcepath(tbname);
   
   if not(any(tbidx))
      
      error('toolbox not in directory');
      
   else
   
      toolboxes(tbidx,:) = [];

      fprintf('\n toolbox %s removed from toolbox directory \n',tbname);

      writetbdirectory(toolboxes,dbpath);
   
   end
   
   % add it to the json directory choices for function 'activate'
   rmjsondirectoryentry(tbname,'activate');
   
   % repeat for 'deactivate'
   rmjsondirectoryentry(tbname,'deactivate');
   
   % remove the source? 
   removetbsourcedir(removesource,tbpath);
   
   
end

function rmjsondirectoryentry(tbname,directoryname)
   
   jspath      = gettbjsonpath(directoryname);
   wholefile   = readtbjsonfile(jspath);
        
   % replace the entry with a blank string, note formatting a bit complex
   % to get comma and single '' around entry right
   tbfind      = sprintf(''',''%s''',tbname);
   tbreplace   = '''';
   wholefile   = strrep(wholefile,tbfind,tbreplace);
   
   % write it over again
   writetbjsonfile(jspath,wholefile);

end
   
   
   
   
   
   
   
   