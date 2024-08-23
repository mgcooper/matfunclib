function mustBeNumericOrDatetime(A)
   %MUSTBENUMERICORDATETIME Validate that value is numeric or datetime
   %
   %    mustBeNumericOrDatetime(A)
   %
   %  Description:
   %
   %    MUSTBENUMERICORDATETIME(A) throws an error if A contains values that are
   %    not numeric or datetime. The function calls isnumeric to determine if A
   %    is numeric and calls isdatetime to determine if A is datetime.
   %
   %  See also: ISNUMERIC, ISDATETIME, MUSTBENUMERIC, MUSTBENUMERICORLOGICAL.

   %  Written by Matt Cooper, github.com/mgcooper
   %  Inspired by MustBeNumericOrLogical, by The MathWorks, Inc.

   if ~isnumeric(A) && ~isdatetime(A)
      eid = 'custom:validators:mustBeNumericOrDatetime';
      msg = 'Value must be numeric or datetime.';
      throwAsCaller(MException(eid, msg));
   end
end
