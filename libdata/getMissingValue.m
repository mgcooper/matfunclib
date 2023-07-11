function missingVal = getMissingValue(propClass)
% Returns appropriate missing value based on property class

% Note; built-in standardizeMissing might work

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