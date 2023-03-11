function out = tocellstr(in)
%TOCELLSTR convert char and string arrays to cellstr, or return cellstr input

validateattributes(in,{'string','cell','char'},{'vector'},mfilename,'in',1)

if iscellstr(in)
   out = in;
else
   out = cellstr(in);
end