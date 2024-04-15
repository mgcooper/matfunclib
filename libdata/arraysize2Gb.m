function memoryGB = arraysize2Gb(dimsizes, dtype)

   if nargin < 2
      dtype = 'double';
   end

   % Calculate the bytes per element based on data type
   bytesPerObject = 0;
   switch dtype
      case {'single', 'float'}
         bytesPerElement = 4;
      case 'double'
         bytesPerElement = 8;
      case {'int64', 'uint64'}
         bytesPerElement = 8;
      case {'int32', 'uint32'}
         bytesPerElement = 4;
      case {'int16', 'uint16'}
         bytesPerElement = 2;
      case {'int8', 'uint8'}
         bytesPerElement = 1;
      case 'string'
         bytesPerElement = 52;
         bytesPerObject = 96;
      case 'char'
         bytesPerElement = 2;

         % These are ambiguous, I think cellstr depends on number of chars per
         % element, and cell can hold any type.
         % case 'cellstr'
         %    bytesPerElement = 106;
         %    bytesPerObject = 0;
         % case 'cell'
         %    bytesPerElement = 112;
         %    bytesPerObject = 0;
      otherwise
         error('Unsupported data type. Choose ''single'' or ''double''.');
   end

   numElements = prod(dimsizes);
   memoryBytes = bytesPerObject + numElements * bytesPerElement;

   % Convert from bytes to GB
   memoryGB = memoryBytes / 1024^3; % 1GB = 1024^3 bytes

end
