function varargout = rmtoolbox(tbname,varargin)
   %RMTOOLBOX Remove toolbox from directory and optionally delete it.
   %
   %    rmtoolbox(tbname)
   %    toolboxes = rmtoolbox(tbname)
   %    toolboxes = rmtoolbox(tbname, 'rmsource', true)
   %
   %  Description
   %
   %    TOOLBOXES = rmtoolbox(TBNAME) removes TBNAME entry in TOOLBOXES
   %    directory and resaves the toolbox directory file.
   %
   %    TOOLBOXES = rmtoolbox(TBNAME, 'RMSOURCE', TRUE) also removes the source
   %    folder. Option "recycle" "on" is set prior to deletion to ensure the
   %    folder is moved to the trash bin, if it needs to be recovered.
   %
   % See also: renametoolbox, addtoolbox, activate, deactivate

   % PARSE INPUTS
   [tbname, rmsource] = parseinputs(tbname, mfilename, varargin{:});

   % Confirm the toolbox exists
   tbname = validatetoolbox(tbname, mfilename, 'TBNAME', 1);

   % Read in the toolbox directory and find the entry for this toolbox
   toolboxes = readtbdirectory(gettbdirectorypath());
   tbindx = findtbentry(toolboxes, tbname);
   tbpath = gettbsourcepath(tbname);

   % Remove the toolbox entry
   toolboxes(tbindx, :) = [];
   fprintf(1, '\n toolbox %s removed from toolbox directory \n', tbname);
   writetbdirectory(toolboxes);

   % Remove the source code if requested
   removetbsourcedir(rmsource, tbpath);

   % manage output
   if nargout == 1
      varargout{1} = toolboxes;
   end
end

%% INPUT PARSER
function [tbname, rmsource] = parseinputs(tbname, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('tbname', @isscalartext);
   parser.addParameter('rmsource', false, @islogical);
   parser.parse(tbname, varargin{:});

   tbname = char(parser.Results.tbname);
   rmsource = parser.Results.rmsource;
end
