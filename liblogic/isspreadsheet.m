function [tf, name, ext] = isspreadsheet(filename, allowemptyname)
   %ISSPREADSHEET Return true if file has a spreadsheet extension.
   %
   %    tf = isspreadsheet(filename)
   %    tf = isspreadsheet(filename, allowemptyname)
   %
   % See also:

   if nargin < 2
      allowemptyname = false;
   end

   [~, name, ext] = fileparts(filename);

   validextensions = {'.xlsx','.xls','.xlsm','.xltx','.xltm','.xls'};

   tf = any(strcmp(ext, validextensions));

   if ~allowemptyname
      tf = tf && ~isempty(name);
   end
end
