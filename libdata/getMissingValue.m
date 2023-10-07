function missingVal = getMissingValue(propClass)
   %GETMISSINGVALUE Return default missing value for class.
   %
   %  missingVal = getMissingValue(propClass)
   %
   % See also: standardizeMissing

   switch propClass
      case 'double'
         missingVal = NaN;
      case 'single'
         missingVal = single(NaN);
      case 'char'
         missingVal = '';
      case 'cell'
         missingVal = {''};
      case 'string'
         missingVal = string(NaN); % <missing>
      case 'categorical'
         missingVal = categorical(NaN); % <undefined>
      case 'datetime'
         missingVal = NaT;
      case {'duration','calendarDuration'};
         missingVal = seconds(NaN);
      otherwise
         error('Unrecognized property class: %s', propClass);
   end
end
