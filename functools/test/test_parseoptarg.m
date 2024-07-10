function tests = test_parseoptarg
   tests = functiontests(localfunctions);
end

function testDefaultOption(testCase)
   inargs = {'nonoption', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, opt, default_option);
   verifyEqual(testCase, inargs, outargs);
   verifyEqual(testCase, nargs, numel(outargs));
end

function testValidOption(testCase)
   inargs = {'option2', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, opt, 'option2');
   verifyEqual(testCase, {42, 'hello'}, outargs);
   verifyEqual(testCase, nargs, numel(outargs));
end

function testMultipleValidOptions(testCase)
   inargs = {'option1', 'option2', 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, opt, 'option1');
   verifyEqual(testCase, outargs, {'option2', 'hello'});
   verifyEqual(testCase, nargs, numel(outargs));
end

function testRemainingArguments(testCase)
   inargs = {'option1', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, outargs, {42, 'hello'});
   verifyEqual(testCase, nargs, numel(outargs));
end

function testArgumentCount(testCase)
   inargs = {'option1', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, nargs, 2);
   verifyEqual(testCase, nargs, numel(outargs));
end

function testNoArguments(testCase)
   inargs = {};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEmpty(testCase, outargs);
end

function testOnlyValidOptions(testCase)
   inargs = {'option1', 'option2'};
   valid_options = inargs;
   default_option = 'option3';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, opt, 'option1');
   verifyEqual(testCase, outargs, {'option2'});
   verifyEqual(testCase, nargs, 1);
   verifyEqual(testCase, nargs, numel(outargs));
end

function testDefaultOptionIsLogical(testCase)
   inargs = {'nonoption', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = true;  % logical default option
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   verifyEqual(testCase, opt, true);
   verifyEqual(testCase, nargs, numel(outargs));
end
