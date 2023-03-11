function namedvalues = structexpand(S,varargin)
%STRUCTEXPAND convert structure of name-value pairs to varargin-like cell array
% 
% 
% See also parser2varargin, namedargs2cell, cellexpand, unmatched2varargin, stringexpand
% 
% NOTE this does exactly what namedargs2cell does

opts = optionParser('asstring',varargin(:));

if opts.asstring == true
   namedvalues = reshape(transpose([string(fieldnames(S)), struct2cell(S)]),1,[]);
else
   namedvalues = reshape(transpose([fieldnames(S) struct2cell(S)]),1,[]);
end