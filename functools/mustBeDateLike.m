function mustBeDateLike(arg)
   %mustBeDateLike validate input argument is date-like
   %
   % argument is a datetime, numeric scalar consistent with datenum
   %
   % Intended for use within arguments block to validate an input
   %
   % Example use in argument block validation:
   %
   % arguments
   %     thisarg { mustBeDateLike(thisarg) };
   % end
   %
   % See also: validators

   if ~isdatelike(arg)

      eid = 'custom:validators:mustBeDateLike';
      msg = 'Value must be a datetime, datenum, or datestr.';
      throwAsCaller(MException(eid, msg));
   end
end
