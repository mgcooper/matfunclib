function tests = test_parseoptarg
   tests = functiontests(localfunctions);
end

function testDefaultOption(testCase)
   inargs = {'nonoption', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(opt, default_option);
   testCase.verifyEqual(inargs, outargs);
   testCase.verifyEqual(nargs, numel(outargs));
end

function testValidOption(testCase)
   inargs = {'option2', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(opt, 'option2');
   testCase.verifyEqual({42, 'hello'}, outargs);
   testCase.verifyEqual(nargs, numel(outargs));
end

function testMultipleValidOptions(testCase)
   inargs = {'option1', 'option2', 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(opt, 'option1');
   testCase.verifyEqual(outargs, {'option2', 'hello'});
   testCase.verifyEqual(nargs, numel(outargs));
end

function testRemainingArguments(testCase)
   inargs = {'option1', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(outargs, {42, 'hello'});
   testCase.verifyEqual(nargs, numel(outargs));
end

function testArgumentCount(testCase)
   inargs = {'option1', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = 'option3';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(nargs, 2);
   testCase.verifyEqual(nargs, numel(outargs));
end

function testNoArguments(testCase)
   inargs = {};
   valid_options = {'option1', 'option2'};
   default_option = 'option1';
   [~, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEmpty(outargs);
end

function testOnlyValidOptions(testCase)
   inargs = {'option1', 'option2'};
   valid_options = inargs;
   default_option = 'option3';
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(opt, 'option1');
   testCase.verifyEqual(outargs, {'option2'});
   testCase.verifyEqual(nargs, 1);
   testCase.verifyEqual(nargs, numel(outargs));
end

function testDefaultOptionIsLogical(testCase)
   inargs = {'nonoption', 42, 'hello'};
   valid_options = {'option1', 'option2'};
   default_option = true;  % logical default option
   [opt, outargs, nargs] = parseoptarg(inargs, valid_options, default_option);
   testCase.verifyEqual(opt, true);
   testCase.verifyEqual(nargs, numel(outargs));
end
