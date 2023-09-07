% Another example of how arguments block simplifies things.
% Note, if validation functions could access properties of the objects they
% validate, it could be simplified further by requiring that varnames be valid
% variable names of table T, which would remove the error check in the else
% block

function T = dropcats(T, varnames)
   % DROPCATS Removes categories that are not present in a table variable
   %
   %  T = DROPCATS(T, VARNAME) takes a table T and the name of a categorical
   %  variable VARNAME. It removes any categories in VARNAME that are not
   %  present in the actual data, and returns the modified table.
   %
   % Example:
   %
   %  T = table(categorical({'a'; 'b'; 'c'}));
   %  T.Var1 = addcats(T.Var1, 'd');
   %  oldcats = categories(T.Variables)
   %  T = gs.dropcats(T, 'Var1');
   %  % Confirm the category 'd' has been removed from the categorical variable:
   %  newcats = categories(T.Variables)
   %
   % Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, github.com/mgcooper
   %
   % See also: removecats, ismember, categories
   
   % PARSE ARGUMENTS
   arguments
      T tabular % Ensure T is a table or other tabular data structure
      varnames (1, :) string = T(:, vartype('categorical')).Properties.VariableNames;
   end
   
   % Confirm there are categorical variables remaining in the table
   if isempty(varnames)
      msg = 'No categorical variables found in the table.';
      eid = 'groupstats:dropcats:nonCategoricalVar';
      error(eid, msg);
   else
      % Confirm the requested variables exist in the table and are categorical
      for var = varnames(:)'
         if ~any(strcmp(var, T.Properties.VariableNames))
            msg = 'Variable name "%s" not found in the table.';
            eid = 'groupstats:dropcats:badVariableName';
            error(eid, msg, var);
         end
         if ~iscategorical(T.(var))
            msg = 'Variable "%s" must be categorical.';
            eid = 'groupstats:dropcats:nonCategoricalVar';
            error(eid, msg, var);
         end
      end
   end
   
   % Iterate through the categorical variables and remove unused categories
   for var = varnames(:)'
      % Retrieve the categories in the given variable
      allcats = categories(T.(var));
   
      % Find categories that are not present in the actual data
      badcats = allcats(~ismember(allcats, T.(var)));
   
      % Remove the unused categories
      T.(var) = removecats(T.(var), badcats);
   end
end