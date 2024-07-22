function mustBeTabular(obj, caller_name, variable_name, argument_position)
   %MUSTBETABULAR Verifies that the input is a table or timetable.
   %
   %  mustBeTabular(obj)
   %  mustBeTabular(obj, caller_name)
   %  mustBeTabular(obj, caller_name, variable_name, argument_position)
   %
   % Description
   %
   %  MUSTBETABULAR(OBJ) verifies that OBJ is a table or timetable. If it isn't,
   %  MUSTBETABULAR issues an error.
   %
   %  MUSTBETABULAR(OBJ, CALLER_NAME) Issues an error message using CALLER_NAME,
   %  the name of the user-level function that is checking the argument.
   %
   %  MUSTBETABULAR(OBJ, CALLER_NAME, VARIABLE_NAME, ARGUMENT_POSITION) Issues
   %  an error message using CALLER_NAME, VARIABLE_NAME, and ARGUMENT_POSITION.
   %  VARIABLE_NAME is the name of the variable in the calling function, and
   %  ARGUMENT_POSITION is the position of the input argument to that function.
   %
   % See also: mustBeStructOrTabular mustBeStruct

   if nargin == 1 || nargin == 2
      if nargin == 1
         caller_name = mcallername();
      end

      eid = 'custom:validators:expectedTabularInput';
      msg = '%s expected input to be a table or timetable.';
      aaa = {upper(caller_name)};

   else
      assert(nargin == 4)
      eid = ['custom:' caller_name ':expectedTabularInput'];
      msg = '%s expected input number %d, %s, to be a table or timetable.';
      aaa = {upper(caller_name), argument_position, upper(variable_name)};
   end

   if ~istabular(obj)
      throwAsCaller(MException(eid, msg, aaa{:}));
   end
end
