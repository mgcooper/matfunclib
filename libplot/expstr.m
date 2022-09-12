function str = expstr(num)
    
    % converts a number to a string of the form 

    aexp    = floor(log10(num));
    str     = sprintf('$1e^{%.f}$',aexp);