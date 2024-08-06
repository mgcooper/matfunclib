function mustBeFolderOrEmpty(arg)
   %mustBeFolderOrEmpty Validate that arg is a folder or empty piece of text.
   %
   %   mustBeFolderOrEmpty(ARG) throws an error if ARG is not a folder found by
   %   ISFOLDER or an empty piece of text.
   %
   %   An empty piece of text is a char or string with one dimension equal to
   %   zero e.g., 0x0, 1x0, or 0x1. An empty string can be created with
   %   string.empty, or string([]). An empty char can be created with
   %   char.empty, char([]), or empty single quotes, ''. Note that "empty"
   %   double quotes "" and string(NaN) (missing string) are not empty (they are
   %   a string scalars).
   %
   %  Example use in argument block validation:
   %    arguments
   %       thisarg { mustBeFolderOrEmpty(arg) };
   %    end
   %
   % See also mustBeFileOrEmpty mustBeFolder mustBeFile mustBeTextScalarOrEmpty

   if ~(isfolder(arg) || isempty(arg))
      eid = 'custom:validators:mustBeFolderOrEmpty';
      msg = ['Value must be a char row vector or scalar string array ' ...
         'representing a folder on the path, or an empty piece of text.'];
      throwAsCaller(MException(eid, msg));
   end
end
