function tests = test_parseparampairs
   tests = functiontests(localfunctions);
end

function testBasicNameValuePairExtraction(testCase)
   % Test basic functionality of parseparampairs

   % Test case 1: No removal of property
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, rmpair] = parseparampairs(inargs);

   % Assertions
   testCase.verifyEqual(outargs, cell(1,0));
   testCase.verifyEqual(pairs, inargs);
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEmpty(rmpair);

   % Test case 2: Remove property 'Name1'
   [outargs, pairs, nargs, rmpair] = parseparampairs(inargs, 'Name1');

   % Assertions
   testCase.verifyEqual(outargs, cell(1,0));
   testCase.verifyEqual(pairs, {'arg1', 'arg2', 'Name2', 'Value2'});
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(rmpair, {'Name1', 'Value1'});
end

function testNoNameValuePair(testCase)

   % Note: this demonstrates how parseparampairs can be confusing and/or
   % requires intelligent use by the caller.
   inargs = {42, 'hello'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);
   testCase.verifyEqual(outargs, {42});
   testCase.verifyEqual(pairs, {'hello'});
   testCase.verifyEqual(nargs, numel(outargs));
end

function testOutputAsStruct(testCase)
   % Test output type as struct

   % Test case 1: Output as struct
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs, 'asstruct');

   % Assertions
   testCase.verifyEqual(outargs, cell(1,0));
   testCase.verifyEqual(fieldnames(pairs), {'arg1'; 'Name1'; 'Name2'});
   testCase.verifyEqual(pairs.Name1, 'Value1');
   testCase.verifyEqual(pairs.Name2, 'Value2');
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));

   % NOTE: this is the correct functionality but incorrect function usage:
   testCase.verifyEqual(pairs.arg1, 'arg2');
end

function testRemoveSpecificPair(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, 'Size');
   testCase.verifyEmpty(outargs);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(pairs, {'Color', 'blue'});
   testCase.verifyEqual(rmpairs, {'Size', 10});
end

function testAllNameValuePairs(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);
   testCase.verifyEmpty(outargs);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(pairs, inargs);
end

function testNonStringElementsBeforeString(testCase)
   inargs = {42, 3.14, 'Color', 'blue'};
   [args, pairs, nargs, ~] = parseparampairs(inargs);
   testCase.verifyEqual(args, {42, 3.14});
   testCase.verifyEqual(pairs, {'Color', 'blue'});
   testCase.verifyEqual(nargs, numel(args));
end

function testWithoutAstypeOption(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [args, pairs, nargs, ~] = parseparampairs(inargs);
   testCase.verifyEmpty(args);
   testCase.verifyEqual(nargs, numel(args));
   testCase.verifyEqual(pairs, {'Color', 'blue', 'Size', 10});
end


function testNoCharArgs(testCase)
   % Test scenario with no character arguments

   % Test case 1: No character arguments
   inargs = {'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);

   % Assertions
   testCase.verifyEqual(outargs, cell(1, 0));
   testCase.verifyEqual(pairs, {'Name1', 'Value1', 'Name2', 'Value2'});
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
end

function testMultipleRmProps(testCase)
   % Test scenario with multiple properties to remove

   % Test case 1a: Remove multiple properties, pass rmprops as a cell array:
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   rmprops = {'Name1', 'Name2'};
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, rmprops);

   % Assertions
   testCase.verifyEqual(outargs, cell(1, 0));
   testCase.verifyEqual(pairs, {'arg1', 'arg2'});
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(rmpairs, {'Name1', 'Value1', 'Name2', 'Value2'});

   % Test case 1a: Remove multiple properties, pass rmprops as a csl:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, rmprops{:});

   % Assertions
   testCase.verifyEqual(outargs, cell(1, 0));
   testCase.verifyEqual(pairs, {'arg1', 'arg2'});
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(rmpairs, {'Name1', 'Value1', 'Name2', 'Value2'});

   % Test case 2a: asstruct output type, pass rmprops as a cell array:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, ...
      'asstruct', rmprops);

   % Assertions
   testCase.verifyEqual(outargs, cell(1, 0));
   testCase.verifyEqual(pairs.arg1, 'arg2');
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(rmpairs.Name1, 'Value1');
   testCase.verifyEqual(rmpairs.Name2, 'Value2');

   % Test case 2b: asstruct output type, pass rmprops as a csl:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, ...
      'asstruct', rmprops{:});

   % Assertions
   testCase.verifyEqual(outargs, cell(1, 0));
   testCase.verifyEqual(pairs.arg1, 'arg2');
   testCase.verifyEqual(nargs, 0);
   testCase.verifyEqual(nargs, numel(outargs));
   testCase.verifyEqual(rmpairs.Name1, 'Value1');
   testCase.verifyEqual(rmpairs.Name2, 'Value2');
end

