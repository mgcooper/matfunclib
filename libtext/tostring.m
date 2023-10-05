function varargout = tostring(stringlike)
   %TOSTRING Cast to string.
   %
   % Examples
   % str = tostring({'1','2'})
   % [str1,str2] = tostring({'1','2'})
   % [str1,str2] = tostring({'1'},{'2'})
   %
   % See also: string, char, makeStringsChars

   % Notes
   % if string.empty() is passed in it will come out as 1x0 empty string
   % if stringlike contains non-string-like values, they will be converted to
   % strings e.g. numbers will become their string equivalent.

   % might be enough to just cast to string in arguments block?
   arguments (Repeating)
      stringlike (1,:) string
   end

   [varargout{1:nargout}] = stringlike{:};
end

% NOTE: This makes it work as in the examples, where the behavior varies based
% on how many outputs are requeested, it makes it flexible, so I can request all
% eleemtns of the input come out as their onw output, or they all come out in
% one array, but that could be confusing, so for now, i went with the more
% predictable version above, but keep this fo rrefrrecen:
% try
%    [varargout{1:nargout}] = stringlike{:};
% catch
%    [varargout{1:nargout}] = deal(stringlike{:});
% end


% function stringlike = tostring(stringlike)
%
% % might be enough to just cast to string in arguments block?
% arguments (Repeating)
%    stringlike (1,:) string
% end
%
% % for calling syntax like this: stringlike = tostring('1',"2",{'3'}), the output
% % will be: {["1"]}    {["2"]}    {["3"]}, so this
% try
%    stringlike = string(stringlike{:});
% catch
%    if iscell(stringlike)
%       stringlike = horzcat(stringlike{:});
%    end
% end


% function varargout = tostring(varargin)
%
% for n = 1:numel(nargout)
%    var = varargin{n};
%    if ischar(var) || iscellstr(var)
%       try
%          varargout{n} = string(var);
%       catch ME
%          varargout{n} = var;
%       end
%    else
%       varargout{n} = var;
%    end
% end
