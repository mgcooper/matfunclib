function filedate = mkfiledate(dateformat)
   if nargin < 1
      dateformat = 'dd-MMM-yyyy_HH-mm-ss';
   end
   filedate = strrep(char(datetime('now', 'Format', dateformat)), '-', '');
end
