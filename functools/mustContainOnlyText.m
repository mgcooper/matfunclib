function mustContainOnlyText(arg)
   %MUSTCONTAINONLYTEXT Validate that input contains only text values.
   %
   %  This validator accepts char arrays, string arrays, and cell arrays whose
   %  contents are text, including mixed char/string cell arrays.
   %
   %  Intended for use inside arguments blocks.
   %
   % Example
   % arguments
   %     thisarg    { mustContainOnlyText(thisarg) };
   % end
   %
   % See also containsOnlyText istextlike ischarlike

   if ~containsOnlyText(arg)
      eid = 'custom:validators:mustContainOnlyText';
      msg = 'Value must be char, string array, or cell array of chars or strings.';
      throwAsCaller(MException(eid, msg));
   end
end
