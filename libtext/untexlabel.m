function newstr = untexlabel(str)
   % UNTEXLABEL Reformat TeX-formatted char to display without TeX interpreter.
   %
   %  NEWSTR = UNTEXLABEL(STR) Re-formats characters from STR so that NEWSTR
   %  will display without any special TeX formatting when used with a TeX
   %  interpreter. STR can be one-row or n-row char, or cellstr.
   %
   %    Example:
   %    untexlabel('c:\matlab\temp\')
   %    ans =
   %    c:\\matlab\\temp\\
   %
   %   $Author: Giuseppe Ridino' $
   %   $Revision: 2.1 $  $Date: 08-Jul-2004 23:46:16 $
   %
   %  See also TEXLABEL

   % initialize output
   newstr = '';
   if ~isempty(str)
      if ischar(str)
         newstr = untexlines(str);
      elseif iscellstr(str)
         newstr = cell(size(str));
         for n = 1:numel(str)
            newstr{n} = untexlines(str{n});
         end
      else
         error('Argument must be a char array or a cell array of strings.')
      end
   end
end

function newstr = untexlines(str)
   % this is for a multiple string line
   newstr = '';
   for n = 1:size(str, 1)
      newstr = strvcat(newstr, untexstring(str(n, :)));
   end
end

function newstr = untexstring(str)
   % this is for a single string line
   newstr = '';
   if ~isempty(str)
      index1 = find(str=='^'); % get '^' index
      index2 = find(str=='_'); % get '_' index
      index3 = find(str=='\'); % get '\' index
      % merge all index
      index_end   = [sort([index1,index2,index3]-1) length(str)];
      index_begin = [1,index_end(1:end-1)+1];
      % build new string
      for counter = 1:length(index_end)-1
         tok = str(index_begin(counter):index_end(counter));
         newstr = strcat(newstr,tok,'\');
      end
      % add end of str
      counter = length(index_end);
      tok = str(index_begin(counter):index_end(counter));
      newstr = strcat(newstr,tok);
   end
end