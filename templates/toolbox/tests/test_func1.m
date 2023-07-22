function tests = testAdd
    tests = functiontests(localfunctions);
end

function testAddition(testCase)
    % Ensure that the function returns the correct sum for positive numbers
    returned = add(3,7);
    expected = 10;
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct sum for negative numbers
    returned = add(-3,-7);
    expected = -10;
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct sum for positive and
    % negative numbers
    returned = add(10,-5);
    expected = 5;
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct sum for zero input
    returned = add(0,0);
    expected = 0;
    verifyEqual(testCase, returned, expected);
end

function testInputValidation(testCase)
    % Ensure that the function raises an error when given non-scalar inputs
    verifyError(testCase, @()add([1,2],3), "MATLAB:validation:IncompatibleSize");
    
    % Ensure that the function raises an error when given non-numeric inputs
    verifyError(testCase, @()add(1,"2"), "MATLAB:validators:mustBeNumeric");
    
    % Ensure that the function raises an error when not given enough input
    % arguments
    verifyError(testCase, @()add(1), "MATLAB:minrhs");
end