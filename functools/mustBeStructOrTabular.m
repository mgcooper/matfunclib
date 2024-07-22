function mustBeStructOrTabular(obj, caller_name, variable_name, argument_position)
   %MUSTBESTRUCTORTABULAR Verifies that input is a struct, table, or timetable.
   %
   %  mustBeStructOrTabular(obj)
   %  mustBeStructOrTabular(obj, caller_name)
   %  mustBeStructOrTabular(obj, caller_name, variable_name, argument_position)
   %
   % Description
   %
   %  MUSTBESTRUCTORTABULAR(OBJ) verifies that OBJ is a struct, table, or
   %  timetable. If it isn't, MUSTBESTRUCTORTABULAR issues an error.
   %
   %  MUSTBESTRUCTORTABULAR(OBJ, CALLER_NAME) Issues an error message using
   %  CALLER_NAME, the name of the user-level function that is checking the
   %  argument.
   %
   %  MUSTBESTRUCTORTABULAR(OBJ, CALLER_NAME, VARIABLE_NAME, ARGUMENT_POSITION)
   %  Issues an error message using CALLER_NAME, VARIABLE_NAME, and
   %  ARGUMENT_POSITION. VARIABLE_NAME is the name of the variable in the
   %  calling function, and ARGUMENT_POSITION is the position of the input
   %  argument to that function.
   %
   %
   % See also: mustBeStruct mustBeTabular mustBeTable mustBeTimetable

   if nargin == 1 || nargin == 2
      if nargin == 1
         caller_name = mcallername();
      end

      eid = 'custom:validators:expectedStructOrTabularInput';
      msg = '%s expected input to be a struct, table, or timetable.';
      aaa = {upper(caller_name)};

   else
      assert(nargin == 4)
      eid = ['custom:' caller_name ':expectedStructOrTabularInput'];
      msg = '%s expected input number %d, %s, to be a struct, table, or timetable.';
      aaa = {upper(caller_name), argument_position, upper(variable_name)};
   end

   if ~isstruct(obj)
      throwAsCaller(MException(eid, msg, aaa{:}));
   end
end
