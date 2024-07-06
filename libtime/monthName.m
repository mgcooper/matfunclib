function name = monthName(monthNumber, kwargs)

   arguments
      monthNumber (1, :) {mustBeNumeric}
      kwargs.format (1, :) string {...
         mustBeMember(kwargs.format, ["name", "shortname"])} = "name"
      kwargs.asstring (1, 1) logical = true
   end

   % Define a cell array of month names
   monthNames = {'January', 'February', 'March', 'April', 'May', 'June', ...
      'July', 'August', 'September', 'October', 'November', 'December'};

   % Access the corresponding month name from the cell array
   name = monthNames(monthNumber);

   if kwargs.format == "shortname"
      % Extract the first three letters of each month name
      name = cellfun(@(x) x(1:3), name, 'UniformOutput', false);
   end

   % If asstring is true, convert cell array to a string array
   if kwargs.asstring
      name = string(name);
   end
end
