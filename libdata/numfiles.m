function [ numfiles ] = numfiles( varargin )
%NUMFILES generates a list of files matching pattern in folder path
%   [ numfiles ] = numfiles( varargin )

if nargin == 0
    filepath = pwd;
    pattern = '*';
elseif nargin == 1
    filepath = varargin{1};
    pattern = '*';
elseif nargin == 2
    filepath = varargin{1};
    pattern = varargin{2};
end

[pattern,pflag] = fixpattern(pattern);

list = dir(fullfile(filepath,pattern));
% list = list([list.isdir]); % activate if you only want folders
list(strncmp({list.name}, '.', 1)) = []; 

% if the pattern is **, only return directories
if pflag==true
    list = list([list.isdir]);
end

numfiles = numel(list);


function [pattern,pflag] = fixpattern(pattern)

pflag=false; % assume the pattern is for files, not directories
% if the pattern is just the suffix e.g. 'tif' or 'mat', add *.
if ~contains(pattern,'.') && ~contains(pattern,'*')
  pattern = ['*.' pattern];
% if the pattern is **, don't adjust it
elseif contains(pattern,'**')
  pflag=true;
  return
% % next two lead to unexpected behavior, try them, they only return the hidden dotfiles        
% % if the pattern has the * but no . add the .    (e.g. *mat)
% elseif contains(pattern,'*') && ~contains(pattern,'.')
%   pattern = [pattern(1) '.' pattern(2:end)];
% % if the pattern has the . but no * add the *   (e.g. .mat)
% elseif contains(pattern,'.') && ~contains(pattern,'*')
%   pattern = ['*' pattern];
end

