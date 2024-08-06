function mustBeTextScalarOrEmpty(arg)
   %mustBeTextScalarOrEmpty Validate that arg is a single piece of text or empty
   %
   %   mustBeTextScalarOrEmpty(TEXT) throws an error if TEXT is not a single
   %   piece of text or an empty piece of text.
   %
   %   For string, a single piece of text is a 1x1 scalar. Empty double quotes,
   %   "", and missing string are text scalars. An empty string is a string with
   %   one dimension equal to zero e.g., 0x0, 1x0, or 0x1, which can be created
   %   by string.empty and string([]). A missing string can be created with
   %   string(NaN).
   %
   %   For char, a single piece of text is a row vector or the special case of
   %   empty single quotes, ''. An empty char can be created with char.empty or
   %   char([]).
   %
   %  This function is based on the Mathworks functions mustBeTextScalar and
   %  mustBeScalarOrEmpty. It is intended for use within arguments block to
   %  validate an input.
   %
   %  Example use in argument block validation:
   %  arguments
   %     thisarg { mustBeTextScalarOrEmpty(arg) };
   %  end
   %
   % See also mustBeTextScalar, mustBeText, mustBeNonzeroLengthText

   if ~(isscalartext(arg) || isempty(arg))
      eid = 'custom:validators:mustBeTextScalarOrEmpty';
      msg = 'Value must be a char row vector, scalar string array, or an empty array.';
      throwAsCaller(MException(eid, msg));
   end
end
