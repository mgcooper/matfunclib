function demo_parseoptarg
   % Call the example_function with a valid option
   disp(newline)
   disp(['Demo 1: selected option' newline]);
   disp('-----------------------')
   disp('Calling syntax: example_function(''option2'', 42, ''hello'')')
   example_function('option2', 42, 'hello');
   disp(newline)

   % Call the example_function without a valid option
   disp('Demo 2: default option');
   disp('-----------------------')
   disp('Calling syntax: example_function(42, ''hello'')')
   example_function(42, 'hello');
end

function example_function(varargin)
    valid_options = {'option1', 'option2'};
    default_option = 'option1';
    
    [selected_option, remaining_args, nargs] = parseoptarg( ...
       varargin, valid_options, default_option);
    
    disp('Valid options: ''option1'', ''option2''');
    disp(['Default option: ', default_option]);
    disp(['Selected option: ', selected_option]);
    disp(['Number of remaining arguments: ', num2str(nargs)]);
    disp('Remaining arguments:');
    disp(remaining_args);
end



