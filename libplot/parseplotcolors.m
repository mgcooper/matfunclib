function C = parseplotcolors(C)
   %PARSEPLOTCOLORS Parse color palette for plot

   % Validate the color palette, using rgb as a backup
   tryrgb = false;
   try
      rgbmat = validatecolor(C, 'multiple');
   catch e
      % If validatecolor fails, C might be valid if it is a color name accepted
      % by RGB. In this case, the error identifier returned by validatecolor
      % will be the one used below, the other error identifiers map to bad
      % numeric inputs or non-vector cellstr or string arrays
      if strcmp(e.identifier, 'MATLAB:graphics:validatecolor:InvalidColorString')
         tryrgb = true;
      else
         rethrow(e)
      end
   end

   if tryrgb
      % Cast strings and chars to cellstr
      C = cellstr(convertStringsToChars(C));
      try
         C = rgb(C{:});
      catch e2
         if strcmp(e2.identifier, 'MATLAB:UndefinedFunction')
            % 'rgb' is not on the user path, throw the error
            warning('function RGB not found')
            rethrow(e2);
         else
            % Throw the validatecolor error
            rethrow(e);
         end
      end
   else
      C = rgbmat;
   end
end

% function C = parseplotcolors(C)
%
%    % This was my original approach before I found validatecolor. This is not
%    % quite finished but it's close
%
%    % Convert strings or chars to cellstr. matlab.graphics.internal.convertToRGB
%    % and rgb both accept cellstr arrays and return nx3 numeric arrays, but do
%    % not accept char vectors representing multiple colors e.g. 'rbym', so
%    % casting to cellstr enables one syntax in subsequent calls
%    if (ischar(C) && isrow(C)) || iscellstr(C) || isstring(C)
%
%       C = convertStringsToChars(C);
%       if ~iscellstr(C) %#ok<*ISCLSTR>
%          C = {C};
%       end
%
%       % Attempt to convert the colors into RGB triplets
%       [rgbmat, notok] = matlab.graphics.internal.convertToRGB(C);
%
%       if isempty(notok)
%          % If all colors were successfully converted, replace the input with
%          % the new RGB triplets.
%          C = rgbmat;
%       else
%          % Defer throwing an error for now in case the input is a special
%          % keyword (i.e. 'default' or 'factory').
%          badColorName = notok(1);
%
%          % Try rgb, which accepts the 949 most common names for colors
%          try
%             C = rgb(C{:});
%          catch e
%             % rethrow(ME);
%          end
%       end
%       % I don't think this is needed, but if 'c' is a scalar string and was not
%       % converted to rgbmat by matlab.graphics.internal.convertToRGB or rgb, then
%       % it is still whatever it was passed in as, and if that was a string, this
%       % convertes to char
%       if isstring(C) && isscalar(C)
%          % Keywords (i.e. 'default' or 'factory') don't work with strings.
%          C = char(C);
%       end
%    else
%       % Ensure C is a nx3 rgb color matrix.
%       validateattributes(C, {'numeric'}, {'ncols', 3}, mfilename, 'C', 1);
%    end
% end
