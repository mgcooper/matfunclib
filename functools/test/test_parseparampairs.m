function tests = test_parseparampairs
   tests = functiontests(localfunctions);
end

function testBasicNameValuePairExtraction(testCase)
   % Test basic functionality of parseparampairs

   % Test case 1: No removal of property
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, rmpair] = parseparampairs(inargs);

   % Assertions
   verifyEqual(testCase, outargs, cell(1,0));
   verifyEqual(testCase, pairs, inargs);
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEmpty(testCase, rmpair);

   % Test case 2: Remove property 'Name1'
   [outargs, pairs, nargs, rmpair] = parseparampairs(inargs, 'Name1');

   % Assertions
   verifyEqual(testCase, outargs, cell(1,0));
   verifyEqual(testCase, pairs, {'arg1', 'arg2', 'Name2', 'Value2'});
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, rmpair, {'Name1', 'Value1'});
end

function testNoNameValuePair(testCase)

   % Note: this demonstrates how parseparampairs can be confusing and/or
   % requires intelligent use by the caller.
   inargs = {42, 'hello'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);
   verifyEqual(testCase, outargs, {42});
   verifyEqual(testCase, pairs, {'hello'});
   verifyEqual(testCase, nargs, numel(outargs));
end

function testOutputAsStruct(testCase)
   % Test output type as struct

   % Test case 1: Output as struct
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs, 'asstruct');

   % Assertions
   verifyEqual(testCase, outargs, cell(1,0));
   verifyEqual(testCase, fieldnames(pairs), {'arg1'; 'Name1'; 'Name2'});
   verifyEqual(testCase, pairs.Name1, 'Value1');
   verifyEqual(testCase, pairs.Name2, 'Value2');
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));

   % NOTE: this is the correct functionality but incorrect function usage:
   verifyEqual(testCase, pairs.arg1, 'arg2');
end

function testRemoveSpecificPair(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, 'Size');
   verifyEmpty(testCase, outargs);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, pairs, {'Color', 'blue'});
   verifyEqual(testCase, rmpairs, {'Size', 10});
end

function testAllNameValuePairs(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);
   verifyEmpty(testCase, outargs);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, pairs, inargs);
end

function testNonStringElementsBeforeString(testCase)
   inargs = {42, 3.14, 'Color', 'blue'};
   [args, pairs, nargs, ~] = parseparampairs(inargs);
   verifyEqual(testCase, args, {42, 3.14});
   verifyEqual(testCase, pairs, {'Color', 'blue'});
   verifyEqual(testCase, nargs, numel(args));
end

function testWithoutAstypeOption(testCase)
   inargs = {'Color', 'blue', 'Size', 10};
   [args, pairs, nargs, ~] = parseparampairs(inargs);
   verifyEmpty(testCase, args);
   verifyEqual(testCase, nargs, numel(args));
   verifyEqual(testCase, pairs, {'Color', 'blue', 'Size', 10});
end


function testNoCharArgs(testCase)
   % Test scenario with no character arguments

   % Test case 1: No character arguments
   inargs = {'Name1', 'Value1', 'Name2', 'Value2'};
   [outargs, pairs, nargs, ~] = parseparampairs(inargs);

   % Assertions
   verifyEqual(testCase, outargs, cell(1, 0));
   verifyEqual(testCase, pairs, {'Name1', 'Value1', 'Name2', 'Value2'});
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
end

function testMultipleRmProps(testCase)
   % Test scenario with multiple properties to remove

   % Test case 1a: Remove multiple properties, pass rmprops as a cell array:
   inargs = {'arg1', 'arg2', 'Name1', 'Value1', 'Name2', 'Value2'};
   rmprops = {'Name1', 'Name2'};
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, rmprops);

   % Assertions
   verifyEqual(testCase, outargs, cell(1, 0));
   verifyEqual(testCase, pairs, {'arg1', 'arg2'});
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, rmpairs, {'Name1', 'Value1', 'Name2', 'Value2'});

   % Test case 1a: Remove multiple properties, pass rmprops as a csl:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, rmprops{:});

   % Assertions
   verifyEqual(testCase, outargs, cell(1, 0));
   verifyEqual(testCase, pairs, {'arg1', 'arg2'});
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, rmpairs, {'Name1', 'Value1', 'Name2', 'Value2'});

   % Test case 2a: asstruct output type, pass rmprops as a cell array:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, ...
      'asstruct', rmprops);

   % Assertions
   verifyEqual(testCase, outargs, cell(1, 0));
   verifyEqual(testCase, pairs.arg1, 'arg2');
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, rmpairs.Name1, 'Value1');
   verifyEqual(testCase, rmpairs.Name2, 'Value2');

   % Test case 2b: asstruct output type, pass rmprops as a csl:
   [outargs, pairs, nargs, rmpairs] = parseparampairs(inargs, ...
      'asstruct', rmprops{:});

   % Assertions
   verifyEqual(testCase, outargs, cell(1, 0));
   verifyEqual(testCase, pairs.arg1, 'arg2');
   verifyEqual(testCase, nargs, 0);
   verifyEqual(testCase, nargs, numel(outargs));
   verifyEqual(testCase, rmpairs.Name1, 'Value1');
   verifyEqual(testCase, rmpairs.Name2, 'Value2');
end

