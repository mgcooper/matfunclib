function mustBeTrue(cond)
%MUSTBETRUE generic validator function
%   
% mustBeTrue(cond) throws an error if COND is false
% 
% Intended for use within arguments block to validate an input
%
% Example use in argument block validation:
% 
% arguments 
%     thisarg    { mustContainOnlyText(thisarg) };
% end
% 
% Copyright (c) 2023, Matt Cooper, BSD 3-Clause License, www.github.com/mgcooper
% 
% See also: validators

if ~islogical(cond) && ischarlike(cond)
   condstr = cond;
   if ~ismember('@', cond)
      func = ['@() ' cond];
   end
   try
      func = str2func(func);
      cond = func();
   catch ME
      
   end
else
   condstr = '';
end

if ~cond
   eid = 'custom:validators:mustBeTrue';
   msg = strrep(sprintf('condition %s must be true.', condstr), '  ', ' ');
   throwAsCaller(MException(eid, msg));
end