function [obj, dropped] = rmvariables(obj, vars, option)
   %RMVARIABLES Remove or keep specified variables from a table or struct
   %
   %   obj = RMVARIABLES(obj, vars)
   %   [obj, dropped] = RMVARIABLES(obj, vars, 'drop')
   %   [obj, dropped] = RMVARIABLES(obj, vars, 'keep')
   %
   % Description
   %
   %   OBJ = RMVARIABLES(OBJ, VARS) removes variables specified by VARS from the
   %   input object OBJ, which can be either a table or a struct.
   %
   %   [OBJ, DROPPED] = RMVARIABLES(OBJ, VARS, OPTION) removes the specified
   %   variables if OPTION='DROP' and keeps them if OPTION='keep'. The dropped
   %   variables are returned in DROPPED.
   %
   % Input Arguments:
   %    obj    - The input object, which can be a table or a struct.
   %    vars   - A column vector of strings specifying the variable names to be
   %             dropped or kept.
   %    option - A string specifying the operation to perform, which can be
   %             either "drop" or "keep". "drop": Removes the specified
   %             variables from the object. "keep": Keeps only the specified
   %             variables in the object and removes the rest.
   %
   % Output Arguments:
   %    obj    - The modified object with variables removed or kept. The type of
   %             obj will match the input type (i.e., if the input was a struct,
   %             the output will also be a struct; if the input was a table, the
   %             output will be a table).
   %    dropped- A string array of the variable names that were removed from
   %             the object.
   %
   % Examples:
   % % Remove Variables from a Struct:
   %  s.a = 1; s.b = 2; s.c = 3;
   %  [s, dropped] = rmvariables(s, ["a", "b"], "drop");
   % % s is now struct with field 'c' only, dropped contains ["a", "b"]
   %
   % % Keep Only Specified Variables in a Table:
   %  T = table([1; 2; 3], [4; 5; 6], 'VariableNames', {'A', 'B'});
   %  [T, dropped] = rmvariables(T, ["A"], "keep");
   % % T is now table with variable 'A' only, dropped contains ["B"]
   %
   % Notes:
   %  -  The function handles both scalar and non-scalar structs.
   %  -  If obj is a struct, it is first converted to a table for variable
   %     removal and then converted back to a struct.
   %  -  The AsArray option is used for struct2table to ensure compatibility
   %     with various struct formats.
   %  -  The ToScalar option in table2struct ensures the output struct matches
   %     the scalar status of the input.
   %
   % See also: parseVariables

   arguments(Input)
      obj
      vars (:, 1) string
      option {mustBeMember(option, ["drop", "keep"])} = "drop"
   end

   wasstruct = isstruct(obj);
   wasscalar = isscalar(obj);
   if wasstruct
      obj = struct2table(obj);
   else
      assert(istabular(obj))
   end

   % Determine fields to remove based on the option
   names = obj.Properties.VariableNames;
   switch option
      case 'drop'
         dropped = intersect(names, vars);
      case 'keep'
         dropped = setdiff(names, vars);
   end

   obj = removevars(obj, dropped);

   if wasstruct
      obj = table2struct(obj, "ToScalar", wasscalar);
   end

   % Note: struct2table should work in all cases, but for reference:
   % AsArray=true means n fields become elements as arrays in a 1xn table
   % AsArray=false means n fields each with m rows becomes an mxn table
end
