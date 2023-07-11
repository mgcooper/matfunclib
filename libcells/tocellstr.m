function out = tocellstr(in)
%TOCELLSTR convert char and string arrays to cellstr, or return cellstr input
% 
%  out = tocellstr(in) converts string, cell, or char array IN to cellstr array
%  OUT
% 
% See also: tocolumn, torow, rowvec

%#ok<*ISCLSTR>
validateattributes(in, {'string','cell','char'}, {'vector'}, mfilename, 'in', 1)
out = ifelse(iscellstr(in), in, cellstr(in));