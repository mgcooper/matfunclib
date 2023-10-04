function mfiles = findSubdir(aDir, varargin)
   % mFileList = findSubdir(aDirectory)
   % mFileList = findSubdir(aDirectory, 'Recurse', tf)

   % Parse input.
   [thedir, Recurse] = parseinputs(aDir, mfilename, varargin{:});

   % Find M-Files.
   dlist = dir(thedir);
   tfdir = [dlist.isdir];
   files = dlist(~tfdir);
   mfiles = files(~cellfun('isempty', regexp({files.name}, '\.m$', 'once')));
   mfiles = cellfun(@(f) fullfile(thedir, f), {mfiles.name}, 'Uniform', false)';

   % If Recurse was specified, find subdirectories.
   if Recurse
      pat = '^\.{1,2}$';
      subdirs = dlist(tfdir & cellfun('isempty', regexp({dlist.name}, pat, 'once')));
      subdirList = {subdirs.name}';
      if ~isempty(subdirList)
         subdirList = strcat(thedir, filesep, subdirList);
         subdirFiles = cellfun(@(d) tbx.internal.findSubdir(d, 'Recurse', Recurse), ...
            subdirList, 'Uniform', false);
         mfiles = vertcat(mfiles, subdirFiles{:});
      end
   end
end

%% input parser
function [FullPath, Recurse] = parseinputs(FullPath, mfuncname, varargin)
   persistent parser;
   if isempty(parser)
      parser = inputParser;
      parser.FunctionName = mfuncname;
      parser.addRequired('FullPath', @(d) ischar(d) && isvector(d));
      parser.addParameter('Recurse', false, @(tf) islogical(tf) && isscalar(tf));
   end
   parser.parse(FullPath, varargin{:});
   thedir = parser.Results.FullPath;
   Recurse = parser.Results.Recurse;
end
