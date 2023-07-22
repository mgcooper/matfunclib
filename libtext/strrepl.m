function stringthing = strrepl(stringthing, oldstr, newstr)
%STRREPL replace substrings in string-like array with new substring
% 
% newstrings = strrepl(stringthing, oldstr, newstr) replaces occurrences of
% oldstr in a string-like thing with newstr. A string-like thing is a 1xN char
% array, cellstr array, or string array. Stringthing is returned in the same
% format as it was passed in as, but is converted to string to perform the
% processing.
% 
% Note: this is *replaced* by the built in function 'replace'. It tries to use
% that first, and if that fails, uses a backup method. 
% 
% Example:
% strrepl('Hello World!', 'World', 'everyone') % returns 'Hello everyone!'
% strrepl('Hello World!', 'world', 'everyone') % returns 'Hello World!'
% strrepl('Hello World!', 'world!', 'everyone') % returns 'Hello World!'
% 
% Matt Cooper, 16-Jun-2023, https://github.com/mgcooper
% 
% See also replace

arguments
   stringthing {mustContainOnlyText(stringthing)}
   oldstr (:, 1) string
   newstr (:, 1) string
end

wascellstr = iscellstr(stringthing); %#ok<*ISCLSTR> 
wascharvec = ischar(stringthing);

% If a char was passed in as a column. Also fixes the (:, 1) cast in arguments.
if wascharvec && iscolumn(stringthing)
   stringthing = stringthing.';
end
   
try
   stringthing = replace(stringthing, oldstr, newstr);
catch
   
   if wascellstr || wascharvec
      stringthing = string(stringthing);
   end
   
   for n = 1:numel(stringthing)
      ok = true;
      try
         newfile = strrep(stringthing(n), oldstr, newstr);
      catch ME
         ok = false;
      end
   
      if ok
         stringthing(n) = newfile;
      end
   end
   
   if wascellstr
      stringthing = cellstr(stringthing);
   elseif wascharvec
      stringthing = char(stringthing);
   end
end