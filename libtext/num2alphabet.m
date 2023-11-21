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

% % Found this after writing above:
% function [let] = num2let(num)
%    % convert number to sequential letter (ala excel)
%    % function [let] = num2let(num)
%    %
%    % inputs  1
%    % num     number               class integer
%    %
%    % outputs 1
%    % let     letter designation   class cell
%    %
%    % michael arant - oct 16 2013
%    % michael arant - jan 2016 - slightly faster code and can handle vectors
%    
%    if nargin < 1
%       help num2let; 
%       error('Need number'); 
%    end
%    if isempty(num)
%       error('Empty number set'); 
%    end
%    if ~isint(num)
%       error('number has to be an integer'); 
%    end
%    
%    % string letters - these are the "base 26" values
%    str = char(97:122);
%    
%    % size output
%    let = cell(size(num));
%    
%    for jj = 1:numel(num)
%    	% build letter (base 26 equlivant to each value)
%    	letn = base102basen(num(jj),26);
%    	% wrap
%    	if numel(letn) > 1 && ~min(letn(2:end))
%    		for ii = numel(letn):-1:2
%    			if letn(ii) < 1
%    				letn(ii) = letn(ii) + 26; letn(ii-1) = letn(ii-1) - 1;
%    			end
%    		end
%    	end
%    	if ~letn(1); letn = letn(2:end); end
%    	% build letters
%    	let{jj} = str(letn);
%    end
% end
% 
% %% convert from base 10 to base n (i.e. 26)
% function [out] = base102basen(num,basen)
%    % convert base n to base m
%    % function [out] = base102basen(num,basen)
%    %
%    % input  2
%    % in     number in base m      class real
%    % basen  output base           class int
%    %
%    % output 1
%    % out    umber in base n       class real
%    %
%    % michael arant - oce 16, 2013
%    
%    if nargin < 2
%       help base102basen; 
%       error('Insuficient inputs'); 
%    end
%    
%    if ~isint(basen)
%       error('basen needs to be an integer'); 
%    end
%    
%    % convert base10 to basen
%    out = []; cnt = 0;
%    while num > 0
%    	cnt = cnt + 1;
%    	out(cnt) = mod(num,basen);
%    	num = floor(num/basen);
%    end
%    out = fliplr(out);
%    % correct decimal
%    if ~isint(out(end))
%    	out(end) = floor(out(end)) + mod(out(end),1) * 10 / basen;
%    end
% end
% 
% %% interget test
% function [res] = isint(val)
%    % determines if value is an integer
%    % function [res] = isint(val)
%    %
%    % inputs  1
%    % val     value to be checked              class real
%    %
%    % outputs 1
%    % res     result (1 is integer, 0 is not)  class integer
%    %
%    % michael arant     may 15, 2004
%    if nargin < 1; help isint; error('I / O error'); end
%    % numeric?
%    if ~isnumeric(val); error('Must be numeric'); end
%    % check for real number
%    if isreal(val) & isnumeric(val)
%       %	check for integer
%    	if round(val) == val
%    		res = 1;
%    	else
%    		res = 0;
%    	end
%    else
%    	res = 0;
%    end
% end
