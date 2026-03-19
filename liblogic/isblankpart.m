function tf = isblankpart(value)
   %ISBLANKPART Return true for blank fullfile-style path parts.
   %
   %  TF = ISBLANKPART(VALUE) returns true when VALUE is either blank text or
   %  an empty cell array. This is useful when building path parts that may
   %  include optional char or string inputs and occasionally empty cell
   %  placeholders from varargin handling.
   %
   %  Non-empty cell arrays are treated as nonblank parts. Cell contents are
   %  not inspected recursively.
   %
   % See also isblanktext

   arguments
      value
   end

   if iscell(value)
      tf = isempty(value);
      return
   end

   tf = isblanktext(value);
end
