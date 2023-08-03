function mFileList = findSubdir(aDir, varargin)
% mFileList = findSubdir(aDirectory)
% mFileList = findSubdir(aDirectory, 'Recurse', tf)

% Parse input.
[aDir, doRecurse] = parseinputs(aDir, mfilename, varargin{:});

% Find M-Files.
theDir = parser.Results.Directory;
dirStruct = dir(theDir);
dirIsDir = [dirStruct.isdir];
fileList = dirStruct(~dirIsDir);
mFileList = fileList(~cellfun('isempty', regexp({fileList.name}, '\.m$', 'once')));
mFileList = cellfun(@(f)fullfile(theDir, f), {mFileList.name}, 'UniformOutput', false)';

% If Recurse was specified, find subdirectories.
if doRecurse
    subdirs = dirStruct(dirIsDir & cellfun('isempty', regexp({dirStruct.name}, '^\.{1,2}$', 'once')));
    subdirList = {subdirs.name}';
    if ~isempty(subdirList)
        subdirList = strcat(theDir, filesep, subdirList);
        subdirFiles = cellfun(@(d)tbx.internal.findSubdir(d, 'Recurse', doRecurse), subdirList, 'UniformOutput', false);
        mFileList = vertcat(mFileList, subdirFiles{:});
    end
end

%% input parser
function [aDir, doRecurse] = parseinputs(aDir, mfuncname, varargin)
persistent parser;
if isempty(parser)
    parser = inputParser;
    parser.FunctionName = mfuncname;
    parser.addRequired('Directory', @(d)ischar(d) && isvector(d));
    parser.addParameter('Recurse', false, @(tf)islogical(tf) && isscalar(tf));
end
parser.parse(aDir, varargin{:});
doRecurse = parser.Results.Recurse;