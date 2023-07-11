function C = nonEmptyCells(C,varargin)
%NONEMPTYCELLS Remove empty cells from cell array C
% 
%  C = NONEMPTYCELLS(C) removes empty cells from cell array C
% 
% Example
%  
% 
% Matt Cooper, 13-Apr-2023, https://github.com/mgcooper
% 
% See also

% input checks
% narginchk(1,2)

% valid options
% validopts = {''}; % can be a single char
% opts = optionParser(validopts,varargin(:)); 

C = C(cellfun(@(c) ~isempty(c), C));










