function [leftDigits, rightDigits] = countDigits(num)
   % Check if the input is numeric
   if ~isnumeric(num) || numel(num) ~= 1
      error('Input must be a numeric scalar.');
   end

   % Convert the number to string
   numStr = num2str(num, '%.15f');  % Use 15 decimal places for accuracy

   % Split the string into whole and decimal parts
   parts = strsplit(numStr, '.');
   wholePart = parts{1};
   decimalPart = parts{2};

   % Count the digits in the whole part
   leftDigits = length(wholePart);

   % Remove trailing zeros in the decimal part
   decimalPart = regexprep(decimalPart, '0*$', '');

   % Count the digits in the decimal part
   rightDigits = length(decimalPart);
end
