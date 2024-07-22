function mustBeTable(obj, caller_name, variable_name, argument_position)
   %MUSTBETABLE Verifies that the input is a table.
   %
   %  mustBeTable(obj)
   %  mustBeTable(obj, caller_name)
   %  mustBeTable(obj, caller_name, variable_name, argument_position)
   %
   % Description
   %
   %  MUSTBETABLE(OBJ) verifies that OBJ is a table. If it isn't, MUSTBETABLE
   %  issues an error.
   %
   %  MUSTBETABLE(OBJ, CALLER_NAME) Issues an error message using CALLER_NAME,
   %  the name of the user-level function that is checking the argument.
   %
   %  MUSTBETABLE(OBJ, CALLER_NAME, VARIABLE_NAME, ARGUMENT_POSITION) Issues an
   %  error message using CALLER_NAME, VARIABLE_NAME, and ARGUMENT_POSITION.
   %  VARIABLE_NAME is the name of the variable in the calling function, and
   %  ARGUMENT_POSITION is the position of the input argument to that function.
   %
   % See also: mustBeTabular mustBeTimetable mustBeStruct mustBeStructOrTabular

   if nargin == 1 || nargin == 2
      if nargin == 1
         caller_name = mcallername();
      end

      eid = 'custom:validators:expectedTableInput';
      msg = '%s expected input to be a table.';
      aaa = {upper(caller_name)};

   else
      assert(nargin == 4)
      eid = ['custom:' caller_name ':expectedTableInput'];
      msg = '%s expected input number %d, %s, to be a table.';
      aaa = {upper(caller_name), argument_position, upper(variable_name)};
   end

   if ~istabular(obj)
      throwAsCaller(MException(eid, msg, aaa{:}));
   end
end
