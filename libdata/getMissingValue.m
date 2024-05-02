function missingVal = getMissingValue(propClass, kwargs)
   %GETMISSINGVALUE Return default missing value for class.
   %
   %  missingVal = getMissingValue(propClass)
   %
   %  Example:
   %  propClass = 'double'; % Example property class
   %  missingVal = getMissingValue(propClass)
   %
   % This documentation is from standardizeMissing
   %
   %   First argument must be numeric, datetime, duration, calendarDuration,
   %   string, categorical, character array, cell array of character vectors,
   %   a table, or a timetable.
   %   Standard missing data is defined as:
   %      NaN                  - for double and single floating-point arrays
   %      NaN                  - for duration and calendarDuration arrays
   %      NaT                  - for datetime arrays
   %      <missing>            - for string arrays
   %      <undefined>          - for categorical arrays
   %      empty character {''} - for cell arrays of character vectors
   %
   % See also: standardizeMissing

   % Notes
   %
   % - "numeric" is not a class but if provided, assume double or single
   % - "logical" does not have an inherent missing value, use NaN
   % - ints do not have an inherent missing value, use 0
   % - string(NaN) = <missing>
   % - categorical(NaN) = <undefined>
   %
   %  With the data itself, rather than the class, could use:
   %
   %  missingVal = standardizeMissing(Data(1), Data(1));
   %
   %  But this requires knowing how to index into Data which differs if its
   %  a numeric array, cell array, etc. Could likely use a series of try-catch,
   %  but for now, the method below covers nearly all standard cases.

   arguments
      propClass (1, :) string
      kwargs.asstring (1, 1) logical = false
   end

   % Create a lookup table using containers.Map
   persistent missingValMap missingValStringMap
   if isempty(missingValMap)

      missingValMap = containers.Map(...
         {'numeric', 'logical', 'double', 'single', 'char', 'cell', 'string', ...
         'categorical', 'datetime', 'duration', 'calendarDuration', 'int8', ...
         'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}, ...
         {NaN, NaN, NaN, single(NaN), '', {''}, string(NaN), ...
         categorical(NaN), NaT, seconds(NaN), seconds(NaN), int8(0), ...
         uint8(0), int16(0), uint16(0), int32(0), uint32(0), int64(0), uint64(0)} ...
         );
   end
   if isempty(missingValStringMap)
      missingValStringMap = containers.Map(...
         {'numeric', 'logical', 'double', 'single', 'char', 'cell', 'string', ...
         'categorical', 'datetime', 'duration', 'calendarDuration', 'int8', ...
         'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}, ...
         {'NaN', 'NaN', 'NaN', 'NaN', 'empty', 'empty', 'missing', ...
         'undefined', 'NaT', 'NaN', 'NaN', '0', ...
         '0', '0', '0', '0', '0', '0', '0'} ...
         );
   end

   if kwargs.asstring == true
      try
         missingVal = string(missingValStringMap(propClass));
      catch ME
         error('Unrecognized property class: %s', propClass);
      end
   else
      try
         missingVal = missingValMap(propClass);
      catch ME
         error('Unrecognized property class: %s', propClass);
      end
   end
end

function missingValueStruct

   % Note that a container is preferable over a struct because isKey can be
   % used to check if a key exists, whereas a struct would require calling
   % fieldnames and then checking.

   % Create a lookup table using a struct
   missingValStruct = struct(...
      'numeric', NaN, ...
      'logical', NaN, ...
      'double', NaN, ...
      'single', single(NaN), ...
      'char', '', ...
      'cell', {''}, ...
      'string', string(NaN), ...
      'categorical', categorical(NaN), ...
      'datetime', NaT, ...
      'duration', seconds(NaN), ...
      'calendarDuration', seconds(NaN), ...
      'int8', int8(0), ...
      'uint8', uint8(0), ...
      'int16', int16(0), ...
      'uint16', uint16(0), ...
      'int32', int32(0), ...
      'uint32', uint32(0), ...
      'int64', int64(0), ...
      'uint64', uint64(0) ...
      );

   % Example of accessing a value
   propClass = 'double'; % Example property class
   missingVal = missingValStruct.(propClass);
end
