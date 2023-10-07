function demo_assertF_Func(x)
   % Define a function that uses assertIf
   
   % assertIf(@() x > 0, 'demo_assertIf_Func:NonPositive', 'Input must be greater than 0.');

   if nargin < 1
      x = 0;
   end
   
   try
      outerFunc(x);  % This will fail the assertion in innerFunc
   catch ME
      fprintf('Caught an error: %s\n', ME.message);
   end

end

% Define some nested functions that use assertF
function outerFunc(x)
   innerFunc(x-1);
end

function innerFunc(x)
   assertF(@() x > 0, 'innerFunc:NonPositive', 'Input must be greater than 0.');
end