function mustBeTimetable(obj, caller_name, variable_name, argument_position)
   %MUSTBETIMETABLE Verifies that the input is a timetable.
   %
   %  mustBeTimetable(obj)
   %  mustBeTimetable(obj, caller_name)
   %  mustBeTimetable(obj, caller_name, variable_name, argument_position)
   %
   % Description
   %
   %  MUSTBETIMETABLE(OBJ) verifies that OBJ is a timetable. If it isn't,
   %  MUSTBETIMETABLE issues an error.
   %
   %  MUSTBETIMETABLE(OBJ, CALLER_NAME) Issues an error message using
   %  CALLER_NAME, the name of the user-level function that is checking the
   %  argument.
   %
   %  MUSTBETIMETABLE(OBJ, CALLER_NAME, VARIABLE_NAME, ARGUMENT_POSITION) Issues
   %  an error message using CALLER_NAME, VARIABLE_NAME, and ARGUMENT_POSITION.
   %  VARIABLE_NAME is the name of the variable in the calling function, and
   %  ARGUMENT_POSITION is the position of the input argument to that function.
   %
   % See also: mustBeTabular mustBeTable mustBeStruct mustBeStructOrTabular

   if nargin == 1 || nargin == 2
      if nargin == 1
         caller_name = mcallername();
      end

      eid = 'custom:validators:expectedTimetableInput';
      msg = '%s expected input to be a timetable.';
      aaa = {upper(caller_name)};

   else
      assert(nargin == 4)
      eid = ['custom:' caller_name ':expectedTimetableInput'];
      msg = '%s expected input number %d, %s, to be a timetable.';
      aaa = {upper(caller_name), argument_position, upper(variable_name)};
   end

   if ~istabular(obj)
      throwAsCaller(MException(eid, msg, aaa{:}));
   end
end
