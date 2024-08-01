function deactivate(tbname, varargin)
   %DEACTIVATE Remove toolbox from path.
   %
   %  DEACTIVATE(TBNAME) Removes toolbox paths from the path and sets the active
   %  property to false in the toolbox directory.
   %
   % See also: activate, workon, workoff

   % Parse inputs.
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('tbname', @isscalartext)
   parser.addParameter('asproject', false, @islogicalscalar);
   parser.parse(tbname, varargin{:})
   tbname = char(tbname);

   % Special case - deactivate a project
   if parser.Results.asproject
      try
         pathadd(getprojectfolder(tbname), 'rmpath', true);
         return
      catch e
         rethrow(e)
      end
   end

   if nargin == 0
      tbname = defaulttbdir;
   elseif nargin == 1
      tbname = char(tbname);
   end

   % Validate that the toolbox exists.
   withwarnoff({'MATFUNCLIB:manager:toolboxAlreadyActive', ...
      'MATLAB:dispatcher:nameConflict', 'MATLAB:rmpath:DirNotFound'});

   % Deactive the toolbox.
   toolboxes = readtbdirectory(gettbdirectorypath());
   if strcmp('all', tbname)

      for tbname = toolboxes.name.'
         toolboxes = deactivateToolbox(tbname{:}, toolboxes);
      end
   else
      [tbname, wid, msg] = validatetoolbox(tbname, mfilename, 'TBNAME', 1);
      if ~isempty(wid)
         warning(wid, msg);
         return
      end
      disp(['deactivating ' tbname]); % alert the user
      toolboxes = deactivateToolbox(tbname, toolboxes);
   end

   % Rewrite the directory.
   writetbdirectory(toolboxes);
end

function toolboxes = deactivateToolbox(tbname, toolboxes)
   %DEACTIVATETOOLBOX Deactivate toolbox.
   withwarnoff({'MATFUNCLIB:manager:toolboxAlreadyActive', ...
      'MATLAB:dispatcher:nameConflict', 'MATLAB:rmpath:DirNotFound'});
   tbidx = findtbentry(toolboxes, tbname);
   tbpath = toolboxes.source{tbidx};
   pathadd(tbpath, 'rmpath', true); % remove toolbox paths
   toolboxes.active(tbidx) = false; % set the active state
end

function tbdir = defaulttbdir
   [~, tbdir] = fileparts(pwd); % if no path was provided, use pwd
end
