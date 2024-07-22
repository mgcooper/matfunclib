function mustBeStruct(obj, caller_name, variable_name, argument_position)
   %MUSTBESTRUCT Verifies that the input is a struct.
   %
   %  mustBeStruct(obj)
   %  mustBeStruct(obj, caller_name)
   %  mustBeStruct(obj, caller_name, variable_name, argument_position)
   %
   % Description
   %
   %  MUSTBESTRUCT(OBJ) verifies that OBJ is a struct. If it isn't, MUSTBESTRUCT
   %  issues an error.
   %
   %  MUSTBESTRUCT(OBJ, CALLER_NAME) Issues an error message using CALLER_NAME,
   %  the name of the user-level function that is checking the argument.
   %
   %  MUSTBESTRUCT(OBJ, CALLER_NAME, VARIABLE_NAME, ARGUMENT_POSITION) Issues an
   %  error message using CALLER_NAME, VARIABLE_NAME, and ARGUMENT_POSITION.
   %  VARIABLE_NAME is the name of the variable in the calling function, and
   %  ARGUMENT_POSITION is the position of the input argument to that function.
   %
   % Based on checkstruct.m
   %
   % See also: mustBeStructOrTabular mustBeTabular mustBeTable mustBeTimetable

   if nargin == 1 || nargin == 2
      if nargin == 1
         caller_name = mcallername();
      end

      eid = 'custom:validators:expectedStructInput';
      msg = '%s expected input to be a struct.';
      aaa = {upper(caller_name)};

   else
      assert(nargin == 4)
      eid = ['custom:' caller_name ':expectedStructInput'];
      msg = '%s expected input number %d, %s, to be a struct.';
      aaa = {upper(caller_name), argument_position, upper(variable_name)};
   end

   if ~isstruct(obj)
      throwAsCaller(MException(eid, msg, aaa{:}));
   end
end
