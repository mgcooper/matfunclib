function toolboxes = addtoolbox(tbname,varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'addtoolbox';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   addRequired(p,'tbname',@(x)ischar(x));
   addOptional(p,'tbactivate','',@(x)ischar(x));

   parse(p,tbname,varargin{:});
   tbname      = p.Results.tbname;
   tbactivate  = p.Results.tbactivate;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   dbpath      = gettbdirectorypath;      % tb database (directory) path
   tbpath      = gettbsourcepath(tbname); % tb source path
   toolboxes   = readtbdirectory(dbpath); % read the directory into memory
   
   tbidx       = height(toolboxes)+1;   
   
   if any(ismember(toolboxes.name,tbname))
      
      error('toolbox already in directory');
      
   else
   
      toolboxes(tbidx,:)      = {tbname,tbpath};

      disp(['adding ' tbname ' to toolbox directory']);

      writetbdirectory(toolboxes,dbpath);
   
   end
   
   % add it to the json directory choices for function 'activate'
   addtojsondirectory(toolboxes,tbidx,'activate');
   
   % repeat for 'deactivate'
   addtojsondirectory(toolboxes,tbidx,'deactivate');
   
   % activate the toolbox if requested
   if string(tbactivate)=="activate"
      activate(tbname);
   end
   
end

function addtojsondirectory(toolboxes,tbidx,directoryname)
   
   jspath      = gettbjsonpath(directoryname);
   wholefile   = readtbjsonfile(jspath);
        
   % replace the most recent entry with itself + the new one
   tbfind      = sprintf('''%s''',toolboxes.name{tbidx-1});
   tbreplace   = sprintf('%s,''%s''',tbfind,toolboxes.name{tbidx});
   wholefile   = strrep(wholefile,tbfind,tbreplace);
   
   % write it over again
   writetbjsonfile(jspath,wholefile)

end
   
   
   
   
   
   
   
   