function opts = optionParser(validopts,varargopts,varargin)
%OPTIONPARSER parse optional inputs. validopts are the options available within
%a function. varargopts is the varargin cell array of optional inputs. opts is
%an optional opts structure that the parsed options are added to
% 
%  opts = optionParser(validopts,varargopts) finds elements of varargopts that
%  are members of validopts and sets them to true in structure opts 
% 
%  opts = optionParser(validopts,varargopts,opts) adds elements of varargopts
%  that are members of validopts to provided structure opts and sets them to
%  true
% 
%  Example 1
% -----------
%  
%  opts = optionParser({'option1','option2','option3'},{'option1'})
%  
% opts = 
% 
%   struct with fields:
% 
%     option1: 1
%     option2: 0
%     option3: 0
% 
%  Example 2
% -----------
% 
% %  set some opts in the calling script
%  opts.makeplots = true;
%  opts.saveplots = false
% 
% %  pass that opts struct to another function and set some new opts relevant
% to the new function
% 
%  function c = myfunc(a,b,opts,varargin)
% 
%  validopts = {'add','multiply'};
%  opts = optionParser(validopts,varargin(:),opts);
% 
%  if opts.add == true && opts.multiply == true
%     error('only one options, add or multiply, can be true');
%  end
% 
%  if opts.add == true
%     c = a+b;
%  elseif opts.multiply == true
%     c = a*b;
%  end
%  
% 

narginchk(2,3);
if nargin == 3
   opts = varargin{1};
else
   opts = struct();
end

for n = 1:numel(validopts)
   if ismember(validopts{n},varargopts)
      opts.(validopts{n}) = true;
   else
      opts.(validopts{n}) = false;
   end
end