clean
% Main script
assertIf on
try
   demo_assertIf_Func(-1);  % This will fail the assertion
catch ME
%    fprintf('Caught an error: %s\n', ME.message);
end

% % Turn off assertion checking and try again
% assertIf off
% try
%    demo_assertIf_Func(-1);  % This will pass because assertion checking is off
% catch ME
% %    fprintf('Caught an error: %s\n', ME.message);
% end
