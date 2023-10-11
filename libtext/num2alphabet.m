function letter = num2alphabet(num)
   %NUM2ALPHABET Convert English letter index to char, with a=1, z=26.
   %
   % letter = num2alphabet(num)
   % 
   % Example
   % letter = num2alphabet(1)
   % letter =
   %     'a'
   %
   % letter = num2alphabet(26)
   % letter =
   %     'z'
   %
   % num2alphabet extends across the entire Unicode numeric range, not just the
   % 1:26 English alphabet. The numbering is remapped to begin at a=1 (z=26),
   % rather than the Unicode code points a=97 (z=122):
   % letter = num2alphabet(864) % double('π') - double('a') + 1
   % letter =
   %     'π'
   % 
   % Use num2alphabet to generate figure panel labels in a loop:
   % figure
   % for n = 1:4
   %    subplot(2, 2, n)
   %    plot(rand(10, 1), rand(10, 1), 'o');
   %    text(-0.2, 1.1, "(" + num2alphabet(n) + ")");
   % end
   % 
   % See also: num2str

   if ischar(num) && isrow(num) || isStringScalar(num)
      num = str2double(num);
   end
   validateattributes(num, {'numeric'}, {'nonempty'}, mfilename, 'NUM', 1)

   letter = char(num + 'a' - 1);
end
