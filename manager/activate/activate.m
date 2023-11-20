function activate(tbname,varargin)
   %ACTIVATE Add toolbox to path and make it the working directory.
   %
   %  activate(TBNAME) activates toolbox TBNAME.
   %
   % See also: addtoolbox, isactive

   % PARSE INPUTS
   [tbname, except, pathloc, postset] = parseinputs(tbname, mfilename, varargin{:});

   % MAIN FUNCTION

   % If the toolbox is active, issue a warning, but suppress warnings about
   % filename conflicts
   withwarnoff('MATLAB:dispatcher:nameConflict');
   [tbname, wid, msg] = validatetoolbox(tbname, mfilename, 'TBNAME', 1);

   % I started to add the onpath check after a situation where startup failed so
   % standard toolboxes were not actually activated but marked active in the 
   % directory, then decided, what's the harm in just adding the toolboxes to
   % the path whether or not they are already active? So I commented out the
   % entire thing
   % if ~isempty(wid)
   %    warning(wid, msg)
   %
   %    % The toolbox could be marked active but not on the path if startup or
   %    % finish errored
   %    % onpath = isfile(tbpath);
   %    % % additional logic to add the toolbox before returning ...
   %
   %    return
   % end

   % Otherwise, proceed with activating the toolbox
   toolboxes = readtbdirectory(gettbdirectorypath);
   tbidx = findtbentry(toolboxes, tbname);

   % Alert the user the toolbox is being activated
   if isempty(except)
      disp(['activating ' tbname])
   else
      disp(strjoin(['activating',tbname,'except',except]))
   end

   % Set the active state
   toolboxes.active(tbidx) = true;

   % Get the toolbox source path
   tbpath = toolboxes.source{tbidx};

   % Add toolbox paths
   pathadd(tbpath, true, pathloc, except, "addpath", true);

   % cd to the activated tb if requested
   if postset == "goto"
      cd(tbpath);
   end

   % Rewrite the directory
   writetbdirectory(toolboxes);
end
%% local functions

function [tbname, except, pathloc, postset] = parseinputs(tbname, funcname, varargin)

   persistent parser
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = funcname;
      parser.addRequired('tbname', @ischarlike);
      parser.addOptional('postset', 'none', @(x) any(validatestring(x, {'goto'})));
      parser.addParameter('except', string.empty(), @ischarlike);
      parser.addParameter('pathloc', '-end', @ischarlike);
   end
   parser.parse(tbname, varargin{:});
   tbname = char(parser.Results.tbname);
   except = string(parser.Results.except);
   postset = string(parser.Results.postset);
   pathloc = string(parser.Results.pathloc);
end
