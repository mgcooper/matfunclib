function foldername = mfoldername(filename,appendpath)
%MFOLDERNAME convert filename to a fullfile path to its parent folder
% 
% Syntax 
% 
% foldername = mfoldername(filename) generates a full path to the parent folder
% of filename e.g. foldername = /full/path/to/filename 
% 
% foldername = mfoldername(mfilename('fullpath')) when used within a matlab
% function generates a full path to filename in the folder containing the
% calling function e.g. filename = /full/path/to/calling/function/
% 
% Inputs
%
% filename: file name of m-file on the user path, or fullpath to m-file. If a
% file name of an m-file is provided, the 'which' command is used to find the
% full path. If a fullpath is provided, it is used as-is.
% 
% appendpath: additional path string that is appended to the foldername, e.g.
% 'data' to save data in a folder named 'data' that is contained within the
% parent folder of filename.
% 
% Examples
% 
% Get the parent folder of a function on your path
% foldername = mfoldername('plot');
% 
% From a calling function:
% foldername = mfoldername(mfilename('fullpath'))
% 
% Append an additional directory
% foldername = mfoldername(mfilename('fullpath'),'data');
% 
% 
% See also localfile

% 
if nargin == 1
   appendpath = "";
end

% the full path to the file was provided
if isfolder(fileparts(filename))
   foldername = fullfile(fileparts(filename),appendpath);
else
   % true if filename is located on the specified path or in the current folder 
   if isfile(filename) 
      % convert filename to fullpath of parent folder
      foldername = fullfile(fileparts(which(filename)),appendpath);
   end
end

% make the folder?
if ~isfolder(foldername)
   mkdir(foldername)
end
