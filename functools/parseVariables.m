function [V, VarNames, InputClass, MissingNames, DroppedNames] = ...
      parseVariables(V, ExpectedNames, kwargs)
   %parseVariables Parse variable names from table and struct
   %
   %  [V, VarNames, InputClass, MissingNames] = parseVariables(V, ExpectedNames)
   %  [_] = parseVariables(_, dropnames=true)
   %
   % Description
   %  [V, VARNAMES, INPUTCLASS, MISSINGNAMES] = PARSEVARIABLES(V, EXPECTEDNAMES)
   %  Returns the variable names of V. If V is of type 'table', VARNAMES is the
   %  VariableNames property. If V is of type 'struct', VARNAMES is the
   %  fieldnames of V. Otherwise VARNAMES is an empty 1x0 string. The class of V
   %  is returned as INPUTCLASS. Variable names present in EXPECTEDNAMES
   %  which are not found in V are returned in MISSINGNAMES.
   %
   %  [_] = PARSEVARIABLES(_, DROPNAMES=TRUE) also removes variables present
   %  in V which are not present in EXPECTEDNAMES. Whereas MISSINGNAMES are
   %  those which do not exist in V, dropped variables are those which do exist
   %  in V but not in EXPECTEDNAMES.
   %
   % See also: rmvariables rmstructfields rmfields removevars

   arguments(Input)
      V
      ExpectedNames (1, :) string = string.empty(1, 0)
      kwargs.dropnames (1, 1) logical = false
   end
   arguments(Output)
      V
      VarNames (1, :) string
      InputClass (1, :) string
      MissingNames (1, :) string
      DroppedNames (1, :) string
   end

   % Set default values
   emptyVariableNames = string.empty(1, 0);
   MissingNames = emptyVariableNames;
   VarNames = emptyVariableNames;

   InputClass = class(V);
   if isempty(ExpectedNames)
      % Keep all variables present in V
      switch InputClass
         case 'struct'
            VarNames = fieldnames(V);
         case 'table'
            VarNames = V.Properties.VariableNames;
         otherwise
            % error('Unsupported InputClass: %s', InputClass);
      end
   else
      % Remove variables which are not present in the supplied VariableNames
      [~, VarNames, DroppedNames, MissingNames] = parseNames( ...
         V, ExpectedNames);

      if kwargs.dropnames
         switch InputClass
            case 'struct'
               V = rmfield(V, DroppedNames);
            case 'table'
               V = removevars(V, DroppedNames);
            otherwise
         end
      end
   end
end
function [names, found, drop, missing] = parseNames(V, expected)

   switch class(V)
      case 'struct'
         names = fieldnames(V);
      case 'table'
         names = V.Properties.VariableNames;
      otherwise
         [names, drop, found, missing] = deal(string.empty(1, 0));
         return
   end

   % Find names which are also in expected names. Does not depend on order.
   found = intersect(expected, names);

   % Find names which are not in expected names.
   drop = setdiff(names, expected);

   % Find expected names which are not in names.
   missing = setdiff(expected, names);
end
