function tbnames = lstoolboxes
tbdirectory = readtbdirectory;
tbnames = tbdirectory.name;
for n = 1:numel(tbnames)
   fprintf(1,'%s%d: %s\n', '    ', n, tbnames{n});
%    if n == activeproject
%       fprintf(2,'%s%d: %s\n', '--> ', n, tbnames{n});
%    else
%       fprintf(1,'%s%d: %s\n', '    ', n, tbnames{n});
%    end
end