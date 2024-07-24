function [V, VarNames, InputClass, MissingNames, ExtraNames] = ...
      parseVariables(V, ExpectedNames, kwargs)
   %PARSEVARIABLES Parse variables and variable names from table or struct.
   %
   %  [V, VarNames, InputClass] = parseVariables(V)
   %  [_, MissingNames, ExtraNames] = parseVariables(V, ExpectedNames)
   %  [_] = parseVariables(_, dropExtraNames=true)
   %
   % Description
   %  [V, VARNAMES, INPUTCLASS] = PARSEVARIABLES(V) returns the variable names
   %  of V. If V is of type 'table', VARNAMES is the VariableNames property. If
   %  V is of type 'struct', VARNAMES is the fieldnames of V. Otherwise VARNAMES
   %  is an empty 1x0 string. The class of V is returned as INPUTCLASS.
   %
   %  [_, MISSINGNAMES, EXTRANAMES] = PARSEVARIABLES(V, EXPECTEDNAMES)
   %  identifies names present in EXPECTEDNAMES which are not found in V, and
   %  returns them in MISSINGNAMES. Names present in V which are not in
   %  EXPECTEDNAMES are returned in EXTRANAMES.
   %
   %  [_] = PARSEVARIABLES(_, DROPEXTRANAMES=TRUE) also removes variables
   %  present in V which are not present in EXPECTEDNAMES (i.e., removes
   %  EXTRANAMES from V).
   %
   %  Note: EXPECTEDNAMES is similar to the VALIDSTR argument to VALIDATESTRING.
   %  However, EXPECTEDNAMES only become strictly valid names if DROPEXTRANAMES
   %  is TRUE. In that case, EXTRANAMES could be considered "INVALIDNAMES" -
   %  names which exist in V but not in EXPECTEDNAMES, and are thus "invalid".
   %  In contrast, MISSINGNAMES are names which exist in EXPECTEDNAMES but are
   %  missing from V.
   %
   % See also: rmvariables rmstructfields rmfields removevars

   arguments(Input)
      V
      ExpectedNames (1, :) string = string.empty(1, 0)
      kwargs.dropExtraNames (1, 1) logical = false
   end
   arguments(Output)
      V
      VarNames (1, :) string
      InputClass (1, :) string
      MissingNames (1, :) string
      ExtraNames (1, :) string
   end

   % parse variable names
   [VarNames, FoundNames, ExtraNames, MissingNames] = parseFieldNames( ...
      V, ExpectedNames, "ExcludePropertyNames", true);

   % Set default values
   InputClass = class(V);

   if isempty(ExpectedNames)
      % Keep all variables present in V

   elseif kwargs.dropExtraNames
      % Remove variables which are not present in the supplied VariableNames

      VarNames = FoundNames;

      switch InputClass
         case 'struct'
            V = rmfield(V, ExtraNames);
         case 'table'
            V = removevars(V, ExtraNames);
         otherwise
      end
   end
end

