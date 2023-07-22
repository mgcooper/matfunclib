function tests = testIntToWord
    tests = functiontests(localfunctions);
end

function testOnesPlace(testCase)
    % Ensure that the function returns the correct English word for ones
    % place numbers
    returned = intToWord(3);
    expected = "three";
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct English word for zero
    returned = intToWord(0);
    expected = "zero";
    verifyEqual(testCase, returned, expected);
end

function testTensPlace(testCase)
    % Ensure that the function returns the correct English word for tens
    % place numbers
    returned = intToWord(20);
    expected = "twenty";
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct English word for "teen"
    % numbers
    returned = intToWord(13);
    expected = "thirteen";
    verifyEqual(testCase, returned, expected);
end

function testHundredsPlace(testCase)
    % Ensure that the function returns the correct English word for
    % hundreds place numbers
    returned = intToWord(345);
    expected = "three hundred forty-five";
    verifyEqual(testCase, returned, expected);
    
    % Ensure that the function returns the correct English word for a
    % number with a zero in the tens place
    returned = intToWord(107);
    expected = "one hundred seven";
    verifyEqual(testCase, returned, expected);
end

function testNegative(testCase)
    % Ensure that the function returns the correct English word for
    % negative numbers
    returned = intToWord(-345);
    expected = "negative three hundred forty-five";
    verifyEqual(testCase, returned, expected);
    
    returned = intToWord(-13);
    expected = "negative thirteen";
    verifyEqual(testCase, returned, expected);

    returned = intToWord(-20);
    expected = "negative twenty";
    verifyEqual(testCase, returned, expected);
end

function testOutOfRange(testCase)
    % Ensure that the function returns a string with the numbers with
    % more than three digits
    returned = intToWord(1000);
    expected = "1000";
    verifyEqual(testCase, returned, expected);
end